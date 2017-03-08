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
                    result = conn.Query<dynamic>(query);
                }
                return result;
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
                        int? maxId=null;
                        if (type == GroupType.ASSET)
                        {
                            var qryParams = Configurator.GetQueryParams(componentName);
                            if (qryParams != null && qryParams.Count == 1)
                            {
                                command.CommandText = Queries.GetSiteGroupMaxID;
                                maxId = (int)command.ExecuteScalar() +1;

                                command.CommandText = GetSiteGroupQuery(maxId.GetValueOrDefault(), qryParams[0].Split(',').ToList());
                                command.ExecuteNonQuery();
                            }
                        }

                        command.CommandText = Queries.ReportInsert;
                        command.Parameters.Add(new SqlParameter("@Name", componentName));
                        command.Parameters.Add(new SqlParameter("@SiteGrpID", maxId));
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
        private static string GetSiteGroupQuery(int siteGrpId,List<string> sites)
        {
            StringBuilder sbuild = new StringBuilder();
            if(sites!=null && sites.Count>0)
            {
                sites.ForEach(site =>
                {
                    sbuild.AppendFormat(Queries.SiteGroupInsert, siteGrpId, site);
                });
            }
            return sbuild.ToString();
        }
    }
}
