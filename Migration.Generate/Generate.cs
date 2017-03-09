using Migration.Common;
using Migration.Configuration.ConfigObject;
using Migration.ProcessQueue;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Migration.Generate
{
    public class Generate
    {
        /// <summary>
        /// Initiates Data Generation Process
        /// </summary>
        /// <param name="components">Components to be executed</param>
        /// <param name="progress">Notify Progress</param>
        /// <returns></returns>
        public async Task Start(Components components, IProgress<ProcessStatus> progress)
        {
            foreach (var grp in components.Group)
            {
                foreach (var comp in grp.Component)
                {
                    progress.Report(new ProcessStatus(comp.Name, 0, Status.Running));
                    var result =  await StartTask(comp);
                    if (result)
                    {
                        progress.Report(new ProcessStatus(comp.Name, 100, Status.Success));
                        Logger.Instance.LogInfo($"Generate task for the component {comp.Name} Succeeded." );
                    }
                    else
                    {
                        progress.Report(new ProcessStatus(comp.Name, 100, Status.Failed));
                    }
                }
            }
            ProcessQueue.ProcessQueue.Processes.CompleteAdding();
            Logger.Instance.LogInfo("Generate Process Completed for Groups :" +string.Join(",",components.Group.Select(t=>t.Name)));
        }

        private async Task<bool> StartTask(Component component)
        {
            bool result = false;
            try
            {
                await Task.Run(() =>
                {
                    result = GenerateFactory.GetGenerator(component.GenerateType).Generate(component);
                });
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError($"Generate task for the component {component.Name} failed.",ex);
            }
            return result;
        }
    }
}
