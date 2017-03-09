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
        /// <summary>
        /// Generates Entities from Old Data and adds it to the Process Queue
        /// </summary>
        /// <param name="component">Component Details</param>
        /// <returns>True, is Success else False.</returns>
        public virtual bool Generate(Component component)
        {
            DateTime startTime = DateTime.Now;
            dynamic resultSet = null;
            List<object> resultEntities = null;
            try
            {
                //Get Data From Legacy/Old Database
                var query = GetSourceQuery(component.Name);
                resultSet = SqlOperation.ExecuteQueryOnSource(query);

                //Get Entity Type
                Type entityType = Type.GetType(component.DomainType);
                if (entityType == null)
                    throw new Exception("Error in Domain Type -" + component.DomainType);

                //Map Data to Entity
                Mapper mapper = new Mapper();
                resultEntities = mapper.Map<object>(resultSet, entityType);
                
                NotifyGenerateStatus(resultSet, resultEntities, component, startTime,"Running");
                ProcessQueue.ProcessQueue.Processes.TryAdd(new ProcessItem(component, resultEntities));
                return true;
            }
            catch (Exception ex)
            {
                NotifyGenerateStatus(resultSet, resultEntities, component, startTime, "Failed");
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
