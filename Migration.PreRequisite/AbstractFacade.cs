using Migration.PreRequisite.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.PreRequisite
{
    public abstract class AbstractFacade
    {
        public abstract List<IPreRequisite> PreRequisites { get;  }
        public abstract string ConnectionString { get; }
        public virtual bool Start(IProgress<PreReqProgress> progress)
        {
            var items = GetNotCompletedItems();
            PreReqProgress status = new PreReqProgress(PreRequisites.Count, PreRequisites.Count-items.Count, new List<PreReqItem>());

            foreach (var item in GetNotCompletedItems())
            {
                var rslt = item.Execute(ConnectionString);
                if(rslt)
                {
                    //Report Progress
                    status.Completed.Add(new PreReqItem(item.Name, PreReqStatus.Completed, 0));
                    status.CompletedCount += 1;
                    progress.Report(status); 
                }
            }
            return true;
        }

        private List<IPreRequisite> GetNotCompletedItems()
        {
            var completed = SqlOperation.GetAllCompletedPreRequisites(ConnectionString);
            return PreRequisites.Where(t => !completed.Contains(t.Name)).ToList();
        }
    }
}
