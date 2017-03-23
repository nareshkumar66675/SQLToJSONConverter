using Migration.Common;
using Migration.PreRequisite.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Migration.PreRequisite
{
    public enum FacadeType
    {
        Legacy,
        Auth,
        Asset
    }
    public abstract class AbstractPreRequisite
    {
        public abstract List<IPreRequisite> PreRequisites { get;  }
        public abstract FacadeType Type { get; }
        public bool Start(IProgress<PreReqProgress> progress)
        {
            try
            {
                var notCompletedPreReqs = GetNotCompletedItems();
                PreReqProgress status = new PreReqProgress(PreRequisites.Count, PreRequisites.Count - notCompletedPreReqs.Count, new List<PreReqItem>());
                //Report Initial Status
                progress?.Report(status);

                foreach (var preReq in notCompletedPreReqs)
                {
                    try
                    {
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
                        }
                        else
                        {
                            NotifyStatus(preReq.Name, PreReqStatus.Failed.ToString());
                            return false;
                        }
                    }
                    catch (Exception ex)
                    {
                        NotifyStatus(preReq.Name, PreReqStatus.Failed.ToString());
                        throw new Exception($"PreRequisite {preReq.Name} Failed", ex);
                    }
                }
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
