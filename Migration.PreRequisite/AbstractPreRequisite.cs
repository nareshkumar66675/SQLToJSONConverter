using Migration.Common;
using Migration.PreRequisite.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Migration.PreRequisite
{
    /// <summary>
    /// Facade Type - PreRequisite
    /// </summary>
    public enum FacadeType
    {
        /// <summary>
        /// Legacy PreRequiste
        /// </summary>
        Legacy,
        /// <summary>
        /// Auth PreRequiste
        /// </summary>
        Auth,
        /// <summary>
        /// Asset PreRequiste
        /// </summary>
        Asset,
        /// <summary>
        /// Report PreRequiste
        /// </summary>
        Report
    }
    public abstract class AbstractPreRequisite
    {
        /// <summary>
        /// List of PreRequisites to be Executed.
        /// PreRequisite should be of type <see cref="IPreRequisite"/> 
        /// </summary>
        public abstract List<IPreRequisite> PreRequisites { get;  }
        /// <summary>
        /// Facade Type
        /// </summary>
        public abstract FacadeType Type { get; }
        /// <summary>
        /// Starts the PreRequisites Execution one by one
        /// which is present in <see cref="PreRequisites"/>
        /// </summary>
        /// <param name="progress">Over all Progress</param>
        /// <returns></returns>
        public bool Start(IProgress<PreReqProgress> progress)
        {
            try
            {
                Logger.Instance.LogInfo("PreRequisites Process started.");

                //Retrieve Not Completed PreRequisites
                var notCompletedPreReqs = GetNotCompletedItems();
                PreReqProgress status = new PreReqProgress(PreRequisites.Count, PreRequisites.Count - notCompletedPreReqs.Count, new List<PreReqItem>());

                //Report Initial Status
                progress?.Report(status);

                foreach (var preReq in notCompletedPreReqs)
                {
                    try
                    {
                        Logger.Instance.LogInfo($"PreRequisite Process started for { preReq.Name}.");

                        var rslt = preReq.Execute();
                        if (rslt)
                        {
                            //Report Progress
                            if (progress != null)
                            {
                                status.Completed.Add(new PreReqItem(preReq.Name, PreReqStatus.Success, 0));
                                ++status.CompletedCount;
                                progress.Report(status);
                            }
                            NotifyStatus(preReq.Name, PreReqStatus.Success.ToString());
                            Logger.Instance.LogInfo($"PreRequisite { preReq.Name} Completed Successfully.");
                        }   
                        else
                        {
                            NotifyStatus(preReq.Name, PreReqStatus.Failed.ToString());
                            Logger.Instance.LogError($"PreRequisite { preReq.Name} Failed",null);
                            return false;
                        }
                    }
                    catch (Exception ex)
                    {
                        NotifyStatus(preReq.Name, PreReqStatus.Failed.ToString());
                        throw new Exception($"PreRequisite {preReq.Name} Failed", ex);
                    }
                }
                Logger.Instance.LogInfo("All PreRequisites Process Completed.");
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error Occurred While Executing PreRequisites", ex);
                return false;
            }
            return true;
        }

        private List<IPreRequisite> GetNotCompletedItems()
        {
            var completed = SqlOperation.GetAllCompletedPreRequisites(Type.GetConnectionString());
            return PreRequisites.Where(t => !completed.Contains(t.Name)).ToList();
        }
        private void NotifyStatus(string name,string status)
        {
            SqlOperation.InsertPreRequisiteStatus(Type.GetConnectionString(),name,status);
        }
    }
}
