using Migration.Common;
using Migration.Configuration;
using Migration.Configuration.ConfigObject;
using Migration.ProcessQueue;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Migration.Persistence
{
    public class Persist
    {
        /// <summary>
        /// Initiates Persistence Operation
        /// </summary>
        /// <param name="progress">Notifier</param>
        /// <returns></returns>
        public async Task Start(IProgress<ProcessStatus> progress)
        {
            while (!ProcessQueue.ProcessQueue.Processes.IsCompleted)
            {

                ProcessItem data = null;
                ProcessQueue.ProcessQueue.Processes.TryTake(out data, 1000);

                if (data != null)
                {
                    progress.Report(new ProcessStatus(data.Component.Name, 0, Status.Running));
                    var rslt = await Task.Run(() => PersistenceFactory.GetPersistenceType(data.Component).Insert(data));

                    if (rslt)
                    {
                        progress.Report(new ProcessStatus(data.Component.Name, 100, Status.Success));
                        Logger.Instance.LogInfo($"Persistence for {data.Component.Name} Completed.");
                    }
                    else
                    {
                        progress.Report(new ProcessStatus(data.Component.Name, 100, Status.Failed));
                        Logger.Instance.LogInfo($"Persistence for {data.Component.Name} Failed.");
                    }
                }
            }
            ProcessQueue.ProcessQueue.Processes.Dispose();
            ProcessQueue.ProcessQueue.Processes = new System.Collections.Concurrent.BlockingCollection<ProcessItem>();
        }
    }
}
