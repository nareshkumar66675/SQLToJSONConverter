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
    public static class SqlOperation
    {
        public static void ExecuteBulkCopy(DataTable data, GroupType type, string destinationTableName)
        {
            using (SqlConnection destinationConnection =
                       new SqlConnection(ConnectionStrings.GetConnectionString(type)))
            {
                destinationConnection.Open();
                using (SqlBulkCopy bulkCopy =
                           new SqlBulkCopy(destinationConnection))
                {
                    bulkCopy.DestinationTableName = destinationTableName;
                    bulkCopy.BatchSize = AppSettings.BulkCopyBatchSize;
                    

                    try
                    {
                        bulkCopy.WriteToServer(data);
                        Logger.Instance.LogInfo("Bulk Copy Completed for table " + destinationTableName);
                    }
                    catch (Exception ex)
                    {
                        Logger.Instance.LogError("Bulk Copy Failed for table " + destinationTableName, ex);
                        throw ex;
                    }
                }
            }
        }
     }
 }
