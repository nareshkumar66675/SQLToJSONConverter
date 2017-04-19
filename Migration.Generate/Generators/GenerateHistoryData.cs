using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Migration.Configuration.ConfigObject;
using Migration.Generate.Helpers;
using Migration.ProcessQueue;

namespace Migration.Generate.Generators
{
    class GenerateHistoryData : GenericGenerator
    {
        public override bool Generate(Component component)
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

                NotifyGenerateStatus(resultSet, resultEntities, component, startTime, "Running");

                //Add to Process Queue for Persisting
                ProcessQueue.ProcessQueue.Processes.TryAdd(new ProcessItem(component, resultEntities));

                return true;
            }
            catch (Exception)
            {
                NotifyGenerateStatus(resultSet, resultEntities, component, startTime, "Failed");
                throw;
            }
        }
    }
}
