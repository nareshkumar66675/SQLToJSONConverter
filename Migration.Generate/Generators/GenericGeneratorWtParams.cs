using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Migration.Configuration.ConfigObject;
using Migration.Configuration;

namespace Migration.Generate.Generators
{
    /// <summary>
    /// Generic Generator With Parameters
    /// </summary>
    public class GenericGeneratorWtParams:GenericGenerator,IGenerator
    {
        /// <summary>
        /// Retrieves Source Query after parsing the Query Params
        /// </summary>
        /// <param name="componentName">Name of the Component</param>
        /// <returns>Query String</returns>
        public override string GetSourceQuery(string componentName)
        {
            string srcQry = string.Empty;
            try
            {
                srcQry = string.Format(Configurator.GetSourceByComponentName(componentName), Configurator.GetQueryParams(componentName).ToArray());
            }
            catch (FormatException ex)
            {
                throw new Exception("Cannot Parse the Query Params", ex);
            }
            return srcQry;
        }
    }
}
