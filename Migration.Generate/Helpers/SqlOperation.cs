using Dapper;
using Migration.Common;
using Migration.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
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
            Stopwatch sw = new Stopwatch();
            try
            {
                dynamic result;
                sw.Start();
                using (var conn = new SqlConnection(ConnectionStrings.LegacyConnectionString))
                {
                    result = conn.Query<dynamic>(query,commandTimeout:AppSettings.SqlCommandTimeout);
                }
                sw.Stop();
                Logger.Instance.LogInfo($"Query Execution Completed. Elapsed Time {sw.Elapsed.ToString(@"hh\:mm\:ss\.fff")}");

                return result;
            }
            catch (Exception)
            {
                sw.Stop();
                Logger.Instance.LogInfo($"Query Execution Completed. Elapsed Time {sw.Elapsed.ToString(@"hh\:mm\:ss\.fff")}");
                throw;
            }
        }
        internal static DataTable ExecuteQuery(string connectionString,string query)
        {
            Stopwatch sw = new Stopwatch();
            try
            {
                DataTable rsltTable = new DataTable();
                sw.Start();

                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.CommandTimeout = AppSettings.SqlCommandTimeout;
                    rsltTable.Load(cmd.ExecuteReader());
                }
                sw.Stop();
                Logger.Instance.LogInfo($"Query Execution Completed. Elapsed Time {sw.Elapsed.ToString(@"hh\:mm\:ss\.fff")}");
                return rsltTable;
            }
            catch (Exception)
            {
                sw.Stop();
                Logger.Instance.LogInfo($"Query Execution Completed. Elapsed Time {sw.Elapsed.ToString(@"hh\:mm\:ss\.fff")}");
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
                        if (type == GroupType.ASSET || type == GroupType.HISTORY)
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
                        }
                        catch (Exception ex1)
                        {
                            throw new Exception("Rollback Failed", ex1);
                        }
                        throw new Exception("Error Ocurred - Rollbacked", ex);
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
        internal static void LoadHistoryData(long siteId)
        {
            using (SqlConnection con = new SqlConnection(ConnectionStrings.LegacyConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("MIGRATION.P_ASSET_SLOT_HISTORY", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = AppSettings.SqlCommandTimeout;
                    cmd.Parameters.Add("@P_SITE_NUMBER", SqlDbType.BigInt).Value = siteId;
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        internal static Dictionary<string, long> GetAllHistoryID()
        {
            //List<string> historyId = new List<string>();
            //using (SqlConnection con = new SqlConnection(ConnectionStrings.LegacyConnectionString))
            //{
            //    using (SqlCommand cmd = new SqlCommand("MIGRATION.P_GET_ASSETID_HISTORY", con))
            //    {
            //        cmd.CommandType = CommandType.StoredProcedure;
            //        cmd.CommandTimeout = AppSettings.SqlCommandTimeout;
            //        con.Open();
            //        using (IDataReader dr = cmd.ExecuteReader())
            //        {
            //            while (dr.Read())
            //            {
            //                historyId.Add(dr.GetInt64(0).ToString());
            //            }
            //        }
            //    }
            //}
            Dictionary<string,long> historyId = new Dictionary<string, long>();
            using (SqlConnection con = new SqlConnection(ConnectionStrings.LegacyConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("MIGRATION.P_GET_ASSETID_HISTORY", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = AppSettings.SqlCommandTimeout;
                    con.Open();
                    using (IDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            historyId.Add(dr.GetInt64(0).ToString(),dr.GetInt64(1));
                        }
                    }
                }
            }
            return historyId;
        }
    }
}
