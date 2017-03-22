using Migration.PreRequisite.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.PreRequisite
{
    public enum FacadeType
    {
        Legacy,
        Auth,
        Asset
    }
    public abstract class AbstractFacade
    {
        public abstract List<IPreRequisite> PreRequisites { get;  }
        public abstract FacadeType Type { get; }
        public virtual bool Start(IProgress<PreReqProgress> progress)
        {
            var items = GetNotCompletedItems();
            PreReqProgress status = new PreReqProgress(PreRequisites.Count, PreRequisites.Count-items.Count, new List<PreReqItem>());

            foreach (var item in items)
            {
                var rslt = item.Execute();
                if(rslt)
                {
                    //Report Progress
                    if (progress!=null)
                    {
                        status.Completed.Add(new PreReqItem(item.Name, PreReqStatus.Success, 0));
                        status.CompletedCount += 1;
                        progress.Report(status); 
                    }
                    NotifyStatus(item.Name, PreReqStatus.Success.ToString());
                }
                else
                {
                    NotifyStatus(item.Name, PreReqStatus.Failed.ToString());
                }
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
