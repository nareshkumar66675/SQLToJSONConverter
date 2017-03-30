using Dapper;
using Migration.Common;
using Migration.Configuration;
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
            try
            {
                dynamic result;
                using (var conn = new SqlConnection(ConnectionStrings.LegacyConnectionString))
                {
                    result = conn.Query<dynamic>(query,commandTimeout:500);
                }
                return result;
            }
            catch (Exception)
            {
                throw;
            }
        }
        internal static DataTable ExecuteQuery(string connectionString,string query)
        {
            try
            {
                DataTable rsltTable = new DataTable();

                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    SqlCommand cmd = new SqlCommand(query, conn);

                    rsltTable.Load(cmd.ExecuteReader());
                }
                return rsltTable;
            }
            catch (Exception)
            {
                throw;
            }
        }
        internal static void InsertGenerateReport(string componentName,DateTime startTime, DateTime endTime, int totalRecordsCount, int totalUniqueRecordsCount,GroupType type,string Status)
        {
            try
            {
                using (var conn = new SqlConnection(ConnectionStrings.GetConnectionString(type)))
                {
                    conn.Open();
                    SqlCommand command = conn.CreateCommand();
                    SqlTransaction transaction;
                    transaction = conn.BeginTransaction("InsertReport");
                    command.Connection = conn;
                    command.Transaction = transaction;
                    try
                    {
                        int? siteGrpID=null;
                        if (type == GroupType.ASSET)
                        {
                            var qryParams = Configurator.GetQueryParams(componentName);
                            if (qryParams != null && qryParams.Count == 1)
                            {
                                //Get Site Group Max ID
                                command.CommandText = Queries.GetSiteGroupMaxID;
                                var max = command.ExecuteScalar();
                                siteGrpID = ((max is DBNull) ? 0 : (int)max) + 1;

                                //Insert Records To Site Group Table
                                command.CommandText = GetSiteGroupQuery(siteGrpID.GetValueOrDefault(), qryParams[0]);
                                command.ExecuteNonQuery();
                            }
                        }
                        //Insert Records to Report Table
                        command.CommandText = Queries.ReportInsert;
                        command.Parameters.Add(new SqlParameter("@Name", componentName));
                        command.Parameters.Add(new SqlParameter("@SiteGrpID",(object) siteGrpID ?? DBNull.Value));
                        command.Parameters.Add(new SqlParameter("@TotRecords", totalRecordsCount));
                        command.Parameters.Add(new SqlParameter("@TotUniqRecords", totalUniqueRecordsCount));
                        command.Parameters.Add(new SqlParameter("@StartTime", startTime));
                        command.Parameters.Add(new SqlParameter("@EndTime", endTime));
                        command.Parameters.Add(new SqlParameter("@Status", Status));
                        command.ExecuteNonQuery();

                        transaction.Commit();
                    }
                    catch (Exception ex)
                    {
                        try
                        {
                            transaction.Rollback();
                            throw new Exception("Error Ocurred - Rollbacked", ex);
                        }
                        catch (Exception)
                        {
                            throw;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError($"Error Occurred While Inserting Generate Report for {componentName} , StartTime - {startTime.ToString()}, totalRecordsCount - {totalRecordsCount}, totalUniqueRecordsCount - {totalUniqueRecordsCount}, Status - {Status}", ex);
            }
        }
        private static string GetSiteGroupQuery(int siteGrpId,string sites)
        {
            StringBuilder sbuild = new StringBuilder();
            using (var legacyConn = new SqlConnection(ConnectionStrings.LegacyConnectionString))
            {
                legacyConn.Open();
                var query = string.Format(Queries.GetSiteDetails, sites);
                using (SqlCommand legacyCommand = new SqlCommand(query, legacyConn))
                {
                    using (IDataReader dr = legacyCommand.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            var siteID = dr.GetInt64(0);
                            var siteName = dr.GetString(1);
                            sbuild.AppendFormat(Queries.SiteGroupInsert,siteGrpId, siteID, siteName);
                        }
                    }
                }
            }
            return sbuild.ToString();
        }
    }
}
