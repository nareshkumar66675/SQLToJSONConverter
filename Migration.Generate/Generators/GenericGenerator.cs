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
            dynamic rslt = null;
            List<object> resultEntities = null;
            try
            {
                var qry = Configuration.Configurator.GetSourceByComponentName(component.Name);
                rslt = SqlOperation.ExecuteQueryOnSource(qry);
                Type type = Type.GetType(component.DomainType);
                Mapper mapper = new Mapper();
                //Slapper.AutoMapper.Configuration.AddIdentifiers(type, new List<string> { "Id","Component.Id", "Component.Components.ComponentValues.Id" });
                resultEntities = mapper.Map<object>(rslt, type);
                NotifyGenerateStatus(rslt, resultEntities, component, startTime,"Running");
                ProcessQueue.ProcessQueue.Processes.TryAdd(new ProcessItem(component, resultEntities));
                return true;
            }
            catch (Exception)
            {
                NotifyGenerateStatus(rslt, resultEntities, component, startTime, "Failed");
                throw;
            }
        }
        private void NotifyGenerateStatus(dynamic src,dynamic mapped ,Component component,DateTime startTime,string status)
        {
            if(AppSettings.IsReportEnabled)
            {
                var totRecordCount = (src as List<object>)?.Count;
                var totUniqueRecordCount = (mapped as List<dynamic>)?.Select(t => t.Id).Distinct()?.Count();
                SqlOperation.InsertGenerateReport(component.Name, startTime,DateTime.Now, totRecordCount??0, totUniqueRecordCount??0,component.GroupName, status);
            }
        }
    }
}
