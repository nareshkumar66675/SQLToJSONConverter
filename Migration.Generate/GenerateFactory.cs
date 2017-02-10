using Migration.Configuration.ConfigObject;
using Migration.Generate.Generators;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Generate
{
    public static class GenerateFactory
    {
        /// <summary>
        /// Used to get Generator Type based on Process Type
        /// </summary>
        /// <param name="processType">Process Type</param>
        /// <returns>Generator Instance</returns>
        public static IGenerator GetGenerator(string processType)
        {
            switch (processType.ToUpper())
            {
                case "DEFAULT":
                    return new GenericGenerator();
                default:
                    return new GenericGenerator();
            }
        }
    }
}
