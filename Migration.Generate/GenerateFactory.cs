using Migration.Configuration.ConfigObject;
using Migration.Generate.Generators;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

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
                case Constants.DEFAULTGENERATE:
                    return new GenericGenerator();
                case Constants.DEFAULTWTPARAMSGENERATE:
                    return new GenericGeneratorWtParams();
                case Constants.AUTHDATAGENERATE:
                    return new AuthReportData();
                case Constants.ASSETDATAGENERATE:
                    return new AssetReportData();
                default:
                    return new GenericGenerator();
            }
        }
    }
}
