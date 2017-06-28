using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.Generate.Generators
{
    /// <summary>
    /// Asset Report Generate
    /// </summary>
    public class AssetReportData : GenerateData
    {
        /// <summary>
        /// Connection String
        /// </summary>
        /// <returns>Returns Asset Connection String</returns>
        public override string GetConnectionString() => ConnectionStrings.GetConnectionString(Common.GroupType.ASSET);

    }
}
