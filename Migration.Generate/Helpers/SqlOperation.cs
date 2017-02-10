using Dapper;
using Migration.Common;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Generate.Helpers
{
    public class SqlOperation
    {
        /// <summary>
        /// Executes the given query
        /// </summary>
        /// <param name="query">Query</param>
        /// <param name="group">Group Type</param>
        /// <returns>Dynamic ResultSet</returns>
        public dynamic ExecuteQuery(string query,GroupType group)
        {
            dynamic result;
            using (var conn = new SqlConnection(Common.Common.ConnectionStrings.SourceConnectionString))
            {
                result = conn.Query<dynamic>(query);
            }
            return result;
        }
    }
}
