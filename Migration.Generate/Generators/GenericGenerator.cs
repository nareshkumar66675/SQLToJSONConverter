using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Migration.Configuration.ConfigObject;
using Migration.Generate.Helpers;
using Migration.ProcessQueue;
using static Migration.Common.Common;

namespace Migration.Generate.Generators
{
    public class GenericGenerator : IGenerator
    {
        public bool Generate(Component component)
        {
            DateTime startTime = DateTime.Now;
            var qry = Configuration.Configurator.GetSourceByComponentName(component.Name);
            dynamic rslt=SqlOperation.ExecuteQueryOnSource(qry);

            Type type = Type.GetType(component.DomainType);
            
            Mapper mapper = new Mapper();
            var resultEntities= mapper.Map<object>(rslt, type);
            NotifyGenerateStatus(rslt, resultEntities, component, startTime);
            ProcessQueue.ProcessQueue.Processes.TryAdd(new ProcessItem(component, resultEntities));

            return true;
        }
        private void NotifyGenerateStatus(dynamic src,dynamic mapped ,Component component,DateTime startTime)
        {
            if(AppSettings.IsReportEnabled)
            {
                var totRecordCount = (src as List<object>).Count;
                var totUniqueRecordCount = (mapped as List<dynamic>).Select(t => t.Id).Distinct().Count();
                SqlOperation.InsertGenerateReport(component.Name, startTime, totRecordCount, totUniqueRecordCount,component.GroupName,"Running");
            }
        }
    }
}
