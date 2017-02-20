﻿using Dapper;
using Migration.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.Generate.Helpers
{
    internal class SqlOperation
    {
        /// <summary>
        /// Executes the given query
        /// </summary>
        /// <param name="query">Query</param>
        /// <returns>Dynamic ResultSet</returns>
        internal static dynamic ExecuteQueryOnSource(string query)
        {
            dynamic result;
            using (var conn = new SqlConnection(ConnectionStrings.LegacyConnectionString))
            {
                result = conn.Query<dynamic>(query);
            }
            return result;
        }

        internal static void InsertGenerateReport(string componentName,DateTime startTime, int totalRecordsCount, int totalUniqueRecordsCount,GroupType type,string Status)
        {
            using (var conn = new SqlConnection(ConnectionStrings.GetConnectionString(type)))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(Queries.ReportInsert, conn);
                cmd.Parameters.Add(new SqlParameter("@Name", componentName));
                cmd.Parameters.Add(new SqlParameter("@TotRecords", totalRecordsCount));
                cmd.Parameters.Add(new SqlParameter("@TotUniqRecords", totalUniqueRecordsCount));
                cmd.Parameters.Add(new SqlParameter("@StartTime", startTime));
                cmd.Parameters.Add(new SqlParameter("@Status", Status));
                cmd.ExecuteNonQuery();
            }
        }
    }
}
