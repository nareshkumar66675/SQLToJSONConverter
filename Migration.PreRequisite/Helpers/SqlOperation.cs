using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Smo;
using Migration.Common;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.PreRequisite.Helpers
{
    internal static class SqlOperation
    {
        internal static bool CheckIfTableExists(string connectionString, string tableName)
        {
            try
            {
                bool exists;
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();
                    var temp = tableName.Split('.');
                    string schema = temp.Length == 2 ? temp[0] : "dbo";
                    string tabName = temp.Length == 2 ? temp[1] : temp[0];
                    using (SqlCommand cmd = new SqlCommand(Queries.CHECKTABLEEXISTS, con))
                    {
                        cmd.Parameters.Add(new SqlParameter("@Schema", schema));
                        cmd.Parameters.Add(new SqlParameter("@TableName", tabName));

                        exists = (int)cmd.ExecuteScalar() == 1;
                    }
                }
                return exists;
            }
            catch (Exception)
            {
                throw;
            }
        }
        internal static void ExecuteBulkCopy(DataTable data, string connectionString, string destinationTableName)
        {
            using (SqlConnection destinationConnection =
                       new SqlConnection(connectionString))
            {
                destinationConnection.Open();
                using (SqlTransaction transaction = destinationConnection.BeginTransaction())
                {
                    using (SqlBulkCopy bulkCopy =
                               new SqlBulkCopy(destinationConnection, SqlBulkCopyOptions.Default, transaction))
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
                            }
                            catch (Exception ex1)
                            {
                                throw new Exception("Rollback Failed", ex1);
                            }
                            throw new Exception($"Bulk Copy Failed for table { destinationTableName } ", ex);
                        }
                    }
                }
            }
        }
        internal static bool InsertCustomAssetID(string connectionString,string legacyQuery)
        {
            DataTable table = new DataTable();
            /* Retrieves Unused Custom Asset ID From Legacy */
            try
            {
                using (var conn = new SqlConnection(ConnectionStrings.LegacyConnectionString))
                {
                    conn.Open();
                    using (SqlCommand legacyCommand = new SqlCommand(legacyQuery, conn))
                    {
                        using (IDataReader reader = legacyCommand.ExecuteReader())
                        {
                            table.Load(reader);
                        }
                    }
                }

                /* Insert Unused Custom Id to New Database */
                ExecuteBulkCopy(table, connectionString, Queries.TBLCUSTOMID);
            }
            catch (Exception)
            {
                throw;
            }

            return true;
        }

        internal static string GetDataFromUserMatrix(string query)
        {
            string dataScript = string.Empty;
            try
            {
                dataScript = GetScriptsFromQuery(GetUMConnectionString(), query);
            }
            catch (Exception ex)
            {
                throw new Exception("UserMatrix Retrieval Failed",ex);
            }
            return dataScript;
        }
        internal static string GetScriptsFromQuery(string connectionString,string query)
        {
            StringBuilder dataScript = new StringBuilder();
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (SqlCommand command = new SqlCommand(query, conn))
                    {
                        command.CommandTimeout= AppSettings.SqlCommandTimeout;

                        using (IDataReader dr = command.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                dataScript.Append(dr.GetString(0));
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
                throw;
            }
            return dataScript.ToString();
        }
        internal static List<string> GetAllCompletedPreRequisites(string connectionString)
        {
            try
            {
                List<string> completedList = new List<string>();

                if (!CheckIfTableExists(connectionString, Common.Common.Queries.PreRequisiteTableName))
                    return completedList;

                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    var query = Common.Common.Queries.GetCompletedPreRequisites;
                    using (SqlCommand command = new SqlCommand(query, conn))
                    {
                        using (IDataReader dr = command.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                completedList.Add(dr.GetString(0));
                            }
                        }
                    }
                }
                return completedList;
            }
            catch (Exception)
            {
                throw;
            }
        }

        internal static void InsertPreRequisiteStatus(string connectionString, string name, string status)
        {
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                SqlCommand command = conn.CreateCommand();
                command.Connection = conn;
                try
                {
                    //Insert Records to PreRequisite Status Table
                    command.CommandText = Common.Common.Queries.InsertPreRequisites;
                    command.Parameters.Add(new SqlParameter("@Name", name));
                    command.Parameters.Add(new SqlParameter("@Status", status));
                    command.ExecuteNonQuery();
                }
                catch (Exception)
                {
                    throw;
                }
            }
        }

        internal static bool ExecuteQuery(string connectionString, string query)
        {
            Stopwatch sw = new Stopwatch();
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    sw.Start();

                    conn.Open();

                    /*Using SQL Server SMO Object
                      Since SqlComand Doesn't support scripts with GO*/
                    Server server = new Server();
                    try
                    {
                        server = new Server(new ServerConnection(conn));
                        server.ConnectionContext.StatementTimeout = AppSettings.SqlCommandTimeout;
                        server.ConnectionContext.BeginTransaction();
                        server.ConnectionContext.ExecuteNonQuery(query);
                        server.ConnectionContext.CommitTransaction();
                    }
                    catch (Exception ex)
                    {
                        try
                        {
                            server.ConnectionContext.RollBackTransaction();
                        }
                        catch (Exception ex1)
                        {
                            throw new Exception("Rollback Failed.", ex1);
                        }
                        throw new Exception("Error Ocurred while Executing PreRequisites - Rollbacked", ex);
                    }
                    sw.Stop();
                    Logger.Instance.LogInfo($"PreRequisite Query Execution Completed. Elapsed Time {sw.Elapsed.ToString(@"hh\:mm\:ss\.fff")}");
                }
            }
            catch (Exception ex)
            {
                sw.Stop();
                Logger.Instance.LogError($"Error Occurred while executing queries for PreRequisites. Elapsed Time {sw.Elapsed.ToString(@"hh\:mm\:ss\.fff")}", ex);
                return false;
            }
            return true;
        }
        internal static bool InsertComponentDefinition(string connectionString)
        {
            try
            {
                //Insert Asset Definitions to Legacy Database
                using (var legConn = new SqlConnection(ConnectionStrings.LegacyConnectionString))
                {
                    legConn.Open();
                    SqlCommand command = legConn.CreateCommand();
                    SqlTransaction transaction;
                    transaction = legConn.BeginTransaction("InsertDefiniton");
                    command.Connection = legConn;
                    command.Transaction = transaction;
                    try
                    {

                        /* Check If table Exits and Empty 
                            1 - Table Exists and Empty - Records will be Inserted
                            0 - Table Exists and Not Empty - Records will not be Inserted
                           -1 - Table Not Exists - Error will be thrown
                        */
                        command.CommandText = Queries.CHECKASSETDFN;
                        command.CommandType = CommandType.Text;

                        var rslt = (int)command.ExecuteScalar();

                        if (rslt == 1)
                        {
                            List<string> astDefinitions = new List<string>();

                            //Get Asset Definitions - to Map New Options to Legacy
                            using (var astConn = new SqlConnection(connectionString))
                            {
                                astConn.Open();
                                using (SqlCommand cmd = new SqlCommand(Queries.GETASSETDFN, astConn))
                                {
                                    using (IDataReader dr = cmd.ExecuteReader())
                                    {
                                        while (dr.Read())
                                        {
                                            astDefinitions.Add(dr.GetString(0));
                                        }
                                    }
                                }
                            }

                            //Insert Records to MIGRATION.ASSET_TYPE_DEFN
                            command.CommandText = Queries.SPASSETDFN;
                            command.CommandType = CommandType.StoredProcedure;
                            var sqp = new SqlParameter("@pValue", SqlDbType.VarChar);
                            command.Parameters.Add(sqp);

                            foreach (var item in astDefinitions)
                            {
                                sqp.Value = item;
                                command.ExecuteNonQuery();
                            }
                        }
                        else if (rslt == -1)
                        {
                            throw new Exception("Table MIGRATION.ASSET_TYPE_DEFN not Found in Legacy Database");
                        }

                        transaction.Commit();
                    }
                    catch (Exception ex)
                    {
                        try
                        {
                            transaction.Rollback();
                            throw new Exception("Error Ocurred - Rollbacked", ex);
                        }
                        catch (Exception ex1)
                        {
                            throw new Exception("Rollback Failed.", ex1);
                        }
                    }
                }
                return true;
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError($"Error Occurred While Inserting Asset Defintion IDs ", ex);
                return false;
            }
        }
        internal static bool UpdateGeoData(string connectionString)
        {
            try
            {
                List<string> SiteNo = new List<string>();
                DataTable DashboardCount = new DataTable();
                using (SqlConnection legConn = new SqlConnection(ConnectionStrings.LegacyConnectionString))
                {
                    legConn.Open();
                    using (SqlCommand cmd = new SqlCommand())
                    {
                        cmd.Connection = legConn;
                        /* Get List of Active Site Numbers from Legacy*/
                        cmd.CommandText = Queries.GETALLACTIVESITENO;
                        cmd.CommandType = CommandType.Text;
                        using (IDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                SiteNo.Add(dr[0].ToString());
                            }
                        }

                        /* Get Dashboard Count from Legacy   */
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandText = Queries.SPDASHBAORDCOUNT;

                        SqlDataAdapter adapt = new SqlDataAdapter(cmd);
                        adapt.Fill(DashboardCount);
                    }
                }
                /* Update Geo & Dashboard Data in Asset DB*/
                using (var astConn = new SqlConnection(connectionString))
                {
                    astConn.Open();

                    using (SqlCommand command = new SqlCommand(Queries.SPUPDATEGEODATA, astConn))
                    {
                        if (SiteNo != null && SiteNo.Count > 0)
                        {
                            if (DashboardCount != null && DashboardCount.Rows.Count == 1)
                            {
                                var row = DashboardCount.Rows[0];
                                command.CommandType = CommandType.StoredProcedure;
                                command.Parameters.Add(new SqlParameter("@siteList", string.Join(",", SiteNo)));
                                command.Parameters.Add(new SqlParameter("@TotalSlots", row["TotalSlot"]));
                                command.Parameters.Add(new SqlParameter("@Online", row["Online"]));
                                command.Parameters.Add(new SqlParameter("@Enrolled", row["Enrolled"]));
                                command.Parameters.Add(new SqlParameter("@Connected", row["Connected"]));
                                command.Parameters.Add(new SqlParameter("@Manufacturer", row["Manufacturer"]));
                                command.Parameters.Add(new SqlParameter("@Denom", row["Denom"]));
                                command.Parameters.Add(new SqlParameter("@Progressive", row["Progressive"]));
                                command.ExecuteNonQuery();
                            }
                            else
                                throw new Exception("Dashboard Count Error");
                        }
                        else
                            throw new Exception("Site Is Empty - GeoUpdate");
                    }
                }
                return true;
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError($"Error Occurred While Updating Dashboard Data", ex);
                return false;
            }
        }
        internal static string GetConnectionString(this FacadeType type)
        {
            switch (type)
            {
                case FacadeType.Legacy:
                    return ConnectionStrings.LegacyConnectionString;
                case FacadeType.Auth:
                    return ConnectionStrings.AuthConnectionString;
                case FacadeType.Asset:
                    return ConnectionStrings.AssetConnectionString;
                case FacadeType.Report:
                    return ConnectionStrings.ReportConnectionString;
                default:
                    return "";
            }
        }
        #region PrivateMethods
        private static string GetUMConnectionString()
        {
            var temp = ConfigurationManager.ConnectionStrings["UserMatrixDB"]?.ConnectionString;
            if (temp == null || string.IsNullOrWhiteSpace(temp))
                throw new Exception("User Matrix DB details not found");
            return temp;
        } 
        #endregion

    }
}
