using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Migration.Configuration.ConfigObject;
using Migration.Generate.Helpers;
using Migration.ProcessQueue;
using static Migration.Common.Common;
using Migration.Common;

namespace Migration.Generate.Generators
{
    public class GenericGenerator : IGenerator
    {
        /// <summary>
        /// Retrieves the Source Query
        /// </summary>
        /// <param name="componentName">Component Name</param>
        /// <returns>Query</returns>
        public virtual string GetSourceQuery(string componentName)
        {
            return Configuration.Configurator.GetSourceByComponentName(componentName);
        }
        public virtual bool Generate(Component component)
        {
            DateTime startTime = DateTime.Now;
            dynamic rslt = null;
            List<object> resultEntities = null;
            try
            {
                var qry = GetSourceQuery(component.Name);
                rslt = SqlOperation.ExecuteQueryOnSource(qry);
                Type type = Type.GetType(component.DomainType);
                if (type == null)
                    throw new Exception("Error in Domain Type -" + component.DomainType);
                Mapper mapper = new Mapper();
                resultEntities = mapper.Map<object>(rslt, type);
                
                NotifyGenerateStatus(rslt, resultEntities, component, startTime,"Running");
                ProcessQueue.ProcessQueue.Processes.TryAdd(new ProcessItem(component, resultEntities));
                return true;
            }
            catch (Exception ex)
            {
                NotifyGenerateStatus(rslt, resultEntities, component, startTime, "Failed");
                throw;
            }
        }
        /// <summary>
        /// Updates Report Table. If Settings allow.
        /// </summary>
        /// <param name="src">Source Data</param>
        /// <param name="mapped">Mapped Data</param>
        /// <param name="component">Component</param>
        /// <param name="startTime">Generation Start Time</param>
        /// <param name="status">Status of Generation</param>
        protected void NotifyGenerateStatus(dynamic src,dynamic mapped ,Component component,DateTime startTime,string status)
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
