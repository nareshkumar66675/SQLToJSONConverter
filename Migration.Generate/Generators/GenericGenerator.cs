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
    public class GenericGenerator : IGenerator
    {
        public bool Generate(Component component)
        {
            SqlOperation sql = new SqlOperation();
            var qry = Configuration.Configurator.GetSourceByComponentName(component.Name);
            dynamic rslt=sql.ExecuteQuery(qry, component.GroupName);

            Type type = Type.GetType(component.DomainType);

            Mapper mapper = new Mapper();
            var resultEntities= mapper.Map<object>(rslt, type);

            ProcessQueue.ProcessQueue.Processes.TryAdd(new ProcessItem(component, resultEntities));

            return true;
        }
    }
}
