using Migration.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace MigrationTool.Helpers
{
    public static class DatabaseHelper
    {
        public static string CheckAndGenerateConnectionString(string serverName, string user, string password, AuthenticationType type)
        {

            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();
            builder.DataSource = serverName;
            builder.UserID = user;
            builder.Password = password;
            builder.IntegratedSecurity = type == AuthenticationType.Windows ? true : false;
            builder.ConnectTimeout = 15;

            SqlConnection connection = new SqlConnection(builder.ConnectionString);
            try
            {
                connection.Open();
                connection.Close();
                builder.ConnectTimeout = 500;
                return builder.ConnectionString;
            }
            catch (SqlException)
            {
                return "";
            }

        }
        public static string GetServerName(string connectionString)
        {
            return new SqlConnectionStringBuilder(connectionString).DataSource;
        }
        public static string GetDatabaseName(string connectionString)
        {
            return new SqlConnectionStringBuilder(connectionString).InitialCatalog;
        }
        public static string AddDatabaseToConnString(string connectionString, string databaseName)
        {
            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(connectionString);
            builder.InitialCatalog = databaseName;
            return builder.ConnectionString;
        }
        public static List<string> GetDatabaseList(string connectionString)
        {
            List<string> list = new List<string>();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand("SELECT name from sys.databases where state_desc<>'OFFLINE'", con))
                {
                    using (IDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            list.Add(dr[0].ToString());
                        }
                    }
                }
            }
            return list;

        }
        public static Dictionary<string, string> GetAllSites(string connectionString)
        {
            Dictionary<string, string> SiteList = new Dictionary<string, string>();
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand("SELECT SITE_NUMBER,Site_Long_Name FROM GAM.VIEW_SITE_INFO order by Site_Long_Name", con))
                {
                    using (IDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            SiteList.Add(dr[0].ToString(), dr[1].ToString());
                        }
                    }
                }
            }
            return SiteList;
        }
        public static List<string> GetMigratedSites(string connectionString)
        {
            List<string> SiteList = new List<string>();

            if (!CheckIfTableExists(connectionString, "Migration.SiteGroup"))
                return SiteList;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                string query = @"SELECT Distinct SiteID FROM [Migration].[SiteGroup] grp 
                                LEFT JOIN[Migration].[Report] rpt on grp.SiteGroupID = rpt.SiteGroupID WHERE rpt.[Status] = 'Success'";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (IDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            SiteList.Add(dr[0].ToString());
                        }
                    }
                }
            }
            return SiteList;
        }
        public static List<string> GetCompletedComponents(GroupType group, List<string> Sites)
        {
            List<string> completedComp = new List<string>();
            try
            {
                string query = string.Empty;
                string conString = string.Empty;
                if (group == GroupType.AUTH)
                {
                    query = "SELECT DISTINCT Component_Name from Migration.Report where Status = 'Success'";
                    conString = Common.ConnectionStrings.AuthConnectionString;
                }
                else if (group == GroupType.ASSET)
                {
                    query = @"SELECT DISTINCT Component_Name FROM Migration.Report rpt
                                LEFT JOIN Migration.SiteGroup grp ON rpt.SiteGroupID=grp.SiteGroupID 
                                WHERE Status='Success' ";
                    conString = Common.ConnectionStrings.AssetConnectionString;
                    if (Sites != null && Sites.Count > 0)
                        query += " AND  (rpt.SiteGroupID IS NULL  OR SiteID IN (" + string.Join(",", Sites) + "))";
                    else
                        query += " AND  (rpt.SiteGroupID IS NULL)";
                }
                using (SqlConnection con = new SqlConnection(conString))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        using (IDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                completedComp.Add(dr.GetString(0));
                            }
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                //throw new InvalidOperationException("Error Occurred While retrieving completed components", ex);
                return new List<string>();//If Migration Tables Not Found - Tables Will be added through Prerequisites
            }
            return completedComp;
        }
        public static bool CheckIfTableExists(string connectionString, string tableName)
        {
            bool exists;
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                string query = @"SELECT CASE WHEN EXISTS((SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=@Schema AND TABLE_NAME = @TableName)) THEN 1 ELSE 0 END";
                var temp = tableName.Split('.');
                string schema = temp.Length == 2 ? temp[0] : "dbo";
                string tabName = temp.Length == 2 ? temp[1] : temp[0];
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.Add(new SqlParameter("@Schema", schema));
                    cmd.Parameters.Add(new SqlParameter("@TableName", tabName));

                    exists = (int)cmd.ExecuteScalar() == 1;
                }
            }
            return exists;
        }
        public static void InsertComponentDefinition()
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
                           -1 - Table Not Exists - Error will ne thrown
                        */
                        command.CommandText = @"IF EXISTS((SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='Migration' AND TABLE_NAME = 'ASSET_TYPE_DEFN')) BEGIN
                                                SELECT CASE WHEN COUNT(ID) > 0 THEN 0 ELSE 1 END from MIGRATION.ASSET_TYPE_DEFN END
                                                ELSE BEGIN SELECT - 1 END";
                        command.CommandType = CommandType.Text;

                        var rslt = (int)command.ExecuteScalar();

                        if(rslt==1)
                        {
                            List<string> astDefinitions = new List<string>();

                            //Get Asset Definitions - to Map New Options to Legacy
                            using (var astConn = new SqlConnection(ConnectionStrings.AssetConnectionString))
                            {
                                astConn.Open();
                                var query = "SELECT Value FROM [ASSET_DEF].[ASSETS]";
                                using (SqlCommand cmd = new SqlCommand(query, astConn))
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
                            command.CommandText = "MIGRATION.P_ASSET_DEFINITION";
                            command.CommandType = CommandType.StoredProcedure;
                            var sqp = new SqlParameter("@pValue", SqlDbType.VarChar);
                            command.Parameters.Add(sqp);

                            foreach (var item in astDefinitions)
                            {
                                sqp.Value = item;
                                command.ExecuteNonQuery();
                            }
                        }
                        else if(rslt == -1)
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
                        catch (Exception)
                        {
                            throw;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.LogError($"Error Occurred While Inserting Asset Defintion IDs ", ex);
            }
        }
    }
}
