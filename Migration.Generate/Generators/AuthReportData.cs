using Migration.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.Generate.Generators
{
    /// <summary>
    /// Generates Auth Report Data
    /// </summary>
    public class AuthReportData : GenerateData
    {
        /// <summary>
        /// To Retrieve Connection String
        /// </summary>
        /// <returns>Auth Connection String</returns>
        public override string GetConnectionString() => ConnectionStrings.GetConnectionString(GroupType.AUTH);

    }
}
