using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Migration.Configuration.ConfigObject;
using Migration.Configuration;

namespace Migration.Generate.Generators
{
    public class GenericGeneratorWtParams:GenericGenerator,IGenerator
    {
        public override string GetSourceQuery(string componentName)
        {
            string srcQry = string.Empty;
            try
            {
                srcQry = string.Format(Configurator.GetSourceByComponentName(componentName), Configurator.GetQueryParams(componentName));
            }
            catch (FormatException ex)
            {
                throw new Exception("Cannot Parse the Query Params", ex);
            }
            return srcQry;
        }
    }
}
