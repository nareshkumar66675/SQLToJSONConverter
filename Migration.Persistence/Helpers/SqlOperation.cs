using Migration.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.Persistence.Helpers
{
    internal static class SqlOperation
    {
        internal static void ExecuteBulkCopy(DataTable data, GroupType type, string destinationTableName)
        {
            using (SqlConnection destinationConnection =
                       new SqlConnection(ConnectionStrings.GetConnectionString(type)))
            {
                destinationConnection.Open();
                using (SqlTransaction transaction = destinationConnection.BeginTransaction())
                {
                    using (SqlBulkCopy bulkCopy =
                               new SqlBulkCopy(destinationConnection,SqlBulkCopyOptions.Default,transaction))
                    {
                        bulkCopy.DestinationTableName = destinationTableName;
                        bulkCopy.BatchSize = AppSettings.BulkCopyBatchSize;
                        bulkCopy.BulkCopyTimeout = AppSettings.SqlCommandTimeout;
                        try
                        {
                            bulkCopy.WriteToServer(data);
                            transaction.Commit();
                            Logger.Instance.LogInfo($"Bulk Copy Completed for table { destinationTableName }");
                        }
                        catch (Exception ex)
                        {
                            try
                            {
                                transaction.Rollback();
                                throw new Exception($"Bulk Copy Failed for table { destinationTableName } ", ex);
                            }
                            catch (Exception ex1)
                            {
                                throw new Exception("Rollback Failed", ex1);
                            }
                        }
                    }
                }
            }
        }
        internal static void UpdatePersistReport(string componentName, DateTime endTime, int totalInsertedRecordsCount, GroupType type,string Status)
        {
            try
            {
                using (var conn = new SqlConnection(ConnectionStrings.GetConnectionString(type)))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(Queries.ReportUpdate, conn);
                    cmd.Parameters.Add(new SqlParameter("@Name", componentName));
                    cmd.Parameters.Add(new SqlParameter("@InsrtdRcrds", totalInsertedRecordsCount));
                    cmd.Parameters.Add(new SqlParameter("@EndTime", endTime));
                    cmd.Parameters.Add(new SqlParameter("@Status", Status));
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError($"Error Occurred While Updating Persist Report : {componentName} , Endtime - {endTime.ToString()} , TotalInsertedRecordsCount - {totalInsertedRecordsCount} , Status - {Status}", ex);
            }
        }
    }
 }
