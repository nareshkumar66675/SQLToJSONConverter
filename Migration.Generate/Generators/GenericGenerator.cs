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
            Mapper mapper = new Mapper();

            try
            {
                //Get Entity Type
                Type entityType = Type.GetType(component.DomainType);
                
                if (entityType == null)
                    throw new Exception("Error in Domain Type -" + component.DomainType);

                //Get Data From Legacy/Old Database
                var query = GetSourceQuery(component.Name);
                resultSet = SqlOperation.ExecuteQueryOnSource(query);

                //Map Column Names
                resultSet = MapColumns(component.Name, resultSet);

                //Map Data to Entity
                resultEntities = mapper.Map<object>(resultSet, entityType);
                
                NotifyGenerateStatus(resultSet, resultEntities, component, startTime,"Running");

                //Add to Process Queue for Persisting
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
                var totRecordCount = (src as IEnumerable<object>)?.Count();
                var totUniqueRecordCount = (mapped as List<dynamic>)?.Select(t => t.Id).Distinct()?.Count();
                SqlOperation.InsertGenerateReport(component.Name, startTime,DateTime.Now, totRecordCount??0, totUniqueRecordCount??0,component.GroupName, status);
            }
        }
        /// <summary>
        /// Renames ResultSet Column Based on Column Mapping
        /// </summary>
        /// <param name="componentName">Component Name</param>
        /// <param name="resultSet">Source Set</param>
        /// <returns>Updated Result Set</returns>
        private dynamic MapColumns(string componentName,dynamic resultSet)
        {
            var mapping = Configuration.Configurator.GetColumnMapping(componentName);

            if (mapping == null || mapping.ColumnMap == null || mapping.ColumnMap.Count < 1)
                return resultSet;

            var srcSet = (resultSet as IEnumerable<object>).Select(dynamicItem => dynamicItem as IDictionary<string, object>).ToList();

            resultSet = null;

            var tempSet= new List<Dictionary<string, object>>();

            if(srcSet!=null)
            {
                srcSet.ForEach(row =>
                {
                    Dictionary<string, object> temp = new Dictionary<string, object>();
                    if (row != null)
                    {
                        foreach (var column in row)
                        {
                            StringBuilder key = new StringBuilder(column.Key);
                            mapping.ColumnMap.ForEach(t => key.Replace(t.Key, t.ColumnName));
                            temp.Add(key.ToString(), column.Value);
                        }
                    }
                    tempSet.Add(temp);
                });
            }

            return tempSet;
        }
    }
}
