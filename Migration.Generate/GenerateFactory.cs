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
        /// Used to get Generator Type based on Generate Type
        /// </summary>
        /// <param name="generateType">Generate Type</param>
        /// <returns>Generator Instance</returns>
        public static IGenerator GetGenerator(string generateType)
        {
            switch (generateType.ToUpper())
            {
                case "DEFAULT":
                    return new GenericGenerator();
                case "DEFAULTWITHPARAMS":
                    return new GenericGeneratorWtParams();
                case "AUTHDATA":
                    return new AuthReportData();
                case "ASSETDATA":
                    return new AssetReportData();
                default:
                    return new GenericGenerator();
            }
        }
    }
}
