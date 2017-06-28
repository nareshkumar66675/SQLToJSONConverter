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

namespace MigrationTool.Helpers
{
    public static class DatabaseHelper
    {
        /// <summary>
        /// Validates the Server Details and Generates a Connection String
        /// </summary>
        /// <param name="serverName">SQL Server Name</param>
        /// <param name="user">Login Name</param>
        /// <param name="password">Password</param>
        /// <param name="type">Authentication Type</param>
        /// <returns>If Success, Connection String else <see cref="string.Empty"/></returns>
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
                return string.Empty;
            }

        }
        /// <summary>
        /// Returns Server Name from Connection String
        /// </summary>
        /// <param name="connectionString">Connection String</param>
        /// <returns>Server Name</returns>
        public static string GetServerName(string connectionString)
        {
            return new SqlConnectionStringBuilder(connectionString).DataSource;
        }
        /// <summary>
        /// Returns Database Name from Connection String
        /// </summary>
        /// <param name="connectionString">Connection String</param>
        /// <returns>Database Name</returns>
        public static string GetDatabaseName(string connectionString)
        {
            return new SqlConnectionStringBuilder(connectionString).InitialCatalog;
        }
        /// <summary>
        /// Returns User Name from Connection String
        /// </summary>
        /// <param name="connectionString">Connection String</param>
        /// <returns></returns>
        public static string GetUserName(string connectionString)
        {
            return new SqlConnectionStringBuilder(connectionString).UserID;
        }
        /// <summary>
        /// Returns Password from Connection String
        /// </summary>
        /// <param name="connectionString">Connection String</param>
        /// <returns></returns>
        public static string GetPassword(string connectionString)
        {
            return new SqlConnectionStringBuilder(connectionString).Password;
        }
        /// <summary>
        /// Returns Authentication Type from Connection String. 
        /// Returns <see cref="AuthenticationType.Windows"></see> if <see cref="SqlConnectionStringBuilder.IntegratedSecurity"/> is true, else 
        /// <see cref="AuthenticationType.SQLServer"/>
        /// </summary>
        /// <param name="connectionString">Connection String</param>
        /// <returns>Returns <see cref="AuthenticationType.Windows"></see> if <see cref="SqlConnectionStringBuilder.IntegratedSecurity"/> is true, else 
        /// <see cref="AuthenticationType.SQLServer"/>/></returns>
        public static AuthenticationType GetAuthenticationType(string connectionString)
        {
            return new SqlConnectionStringBuilder(connectionString).IntegratedSecurity ? AuthenticationType.Windows : AuthenticationType.SQLServer;
        }
        /// <summary>
        /// Add Database to Connection String
        /// </summary>
        /// <param name="connectionString">Connection String</param>
        /// <param name="databaseName">Database Name</param>
        /// <returns>Connection String</returns>
        public static string AddDatabaseToConnString(string connectionString, string databaseName)
        {
            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(connectionString);
            builder.InitialCatalog = databaseName;
            return builder.ConnectionString;
        }
        /// <summary>
        /// Retrieves all Active Database in Server
        /// </summary>
        /// <param name="connectionString">Connection String</param>
        /// <returns>List of Databases</returns>
        public static List<string> GetDatabaseList(string connectionString)
        {
            List<string> databases = new List<string>();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(Queries.GETALLACTIVEDBS, con))
                {
                    using (IDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            databases.Add(dr[0].ToString());
                        }
                    }
                }
            }
            databases.Sort();
            return databases;

        }
        /// <summary>
        /// Retrieves all Sites from Legacy
        /// </summary>
        /// <returns>Site Id & Site Name</returns>
        public static Dictionary<string, string> GetAllSitesFromLegacy()
        {
            Dictionary<string, string> SiteList = new Dictionary<string, string>();
            using (SqlConnection con = new SqlConnection(ConnectionStrings.LegacyConnectionString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(Queries.GETALLACTIVESITES, con))
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
        /// <summary>
        /// Retrieves Report Summary of a particular Group
        /// </summary>
        /// <param name="group">Group Type</param>
        /// <returns>Report Data</returns>
        internal static DataTable GetReportSummary(GroupType group)
        {
            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("Group"));
            table.Columns.Add(new DataColumn("DisplayName"));
            table.Columns.Add(new DataColumn("Site Count"));
            table.Columns.Add(new DataColumn("Legacy Records"));
            table.Columns.Add(new DataColumn("Unique Records"));
            table.Columns.Add(new DataColumn("Inserted Records"));

            if (!string.IsNullOrWhiteSpace(ConnectionStrings.GetConnectionString(group)))
            {
                using (SqlConnection con = new SqlConnection(ConnectionStrings.GetConnectionString(group)))
                {
                    con.Open();

                    using (SqlCommand cmd = new SqlCommand(Queries.GETREPORTSUMMARY, con))
                    {
                        using (IDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                table.Rows.Add( group.GetDescription() // Group Name
                                                , Configurator.GetDisplayNameByComponentName(dr.GetString(0)) // Component_Name -> Display Name
                                                , dr[1].ToString()  //SiteCount
                                                , dr[2].ToString()  //Legacy Count
                                                , dr[3].ToString()  //Unique Count
                                                , dr[4].ToString());//InsertedRcrds Count
                            }
                        }
                    }
                }
            }

            return table;
        }
        /// <summary>
        /// Retrieves all Reports.
        /// Union of all Groups by invoking <see cref="GetReportSummary(GroupType)"/>
        /// </summary>
        /// <returns>Overall Report Data</returns>
        internal static DataTable GetAllReports()
        {
            //Get All Reports From Databases asynchronously
            var authTask =Task.Factory.StartNew(() => GetReportSummary(GroupType.AUTH));
            var assetTask = Task.Factory.StartNew(() => GetReportSummary(GroupType.ASSET));
            var rptTask = Task.Factory.StartNew(() => GetReportSummary(GroupType.REPORT));

            DataTable table = new DataTable();

            //Wait and Union the Results
            authTask.Wait();
            table.Merge(authTask.Result, true, MissingSchemaAction.Add);
            assetTask.Wait();
            table.Merge(assetTask.Result, true, MissingSchemaAction.Add);
            rptTask.Wait();
            table.Merge(rptTask.Result, true, MissingSchemaAction.Add);

            return table;
        }
        /// <summary>
        /// Retrieves all migrated sites
        /// </summary>
        /// <param name="connectionString">Connection String</param>
        /// <returns>List of Migrated Site Id's</returns>
        public static List<string> GetMigratedSites(string connectionString)
        {
            List<string> SiteList = new List<string>();

            if (!CheckIfTableExists(connectionString, Queries.SITEGRPTABNAME))
                return SiteList;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(Queries.GETMIGRATEDSITES, con))
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
        /// <summary>
        /// Retrieves Completed Components
        /// </summary>
        /// <param name="group">Group Type</param>
        /// <param name="Sites">Selected Sites</param>
        /// <returns>List of Completed Compoennts</returns>
        public static List<string> GetCompletedComponents(GroupType group, List<string> Sites)
        {
            List<string> completedComp = new List<string>();
            try
            {
                string query = string.Empty;
                if (group == GroupType.AUTH || group == GroupType.REPORT)
                {
                    query = Queries.GETCOMPITEMSWITHOUTSITE;
                }
                else if (group == GroupType.ASSET)
                {
                    query = Queries.GETCOMPITEMSWITHSITE;

                    if (Sites != null && Sites.Count > 0)
                        query += " AND  (rpt.SiteGroupID IS NULL  OR SiteID IN (" + string.Join(",", Sites) + "))";
                    else
                        query += " AND  (rpt.SiteGroupID IS NULL)";
                }
                using (SqlConnection con = new SqlConnection(ConnectionStrings.GetConnectionString(group)))
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
            catch (SqlException)
            {
                //throw new InvalidOperationException("Error Occurred While retrieving completed components", ex);
                return new List<string>();//If Migration Tables Not Found - Tables Will be added through Prerequisites
            }
            return completedComp;
        }
        /// <summary>
        /// To Check if table exists in a given Database
        /// </summary>
        /// <param name="connectionString">Connection String</param>
        /// <param name="tableName">Table Name</param>
        /// <returns></returns>
        public static bool CheckIfTableExists(string connectionString, string tableName)
        {
            bool exists;
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                var fullTabName = tableName.Split('.');
                string schema = fullTabName.Length == 2 ? fullTabName[0] : "dbo";
                string tabName = fullTabName.Length == 2 ? fullTabName[1] : fullTabName[0];
                using (SqlCommand cmd = new SqlCommand(Queries.CHECKTABLEEXISTS, con))
                {
                    cmd.Parameters.Add(new SqlParameter("@Schema", schema));
                    cmd.Parameters.Add(new SqlParameter("@TableName", tabName));

                    exists = (int)cmd.ExecuteScalar() == 1;
                }
            }
            return exists;
        }
        /// <summary>
        /// To Check if SP exists in a given Database
        /// </summary>
        /// <param name="connectionString">Connection String</param>
        /// <param name="procedureName">Procedure Name</param>
        /// <returns></returns>
        public static bool CheckIfSPExists(string connectionString, string procedureName)
        {
            bool exists;
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(Queries.CHECKSPEXISTS, con))
                {
                    cmd.Parameters.Add(new SqlParameter("@ProcedureName", procedureName));

                    exists = (int)cmd.ExecuteScalar() == 1;
                }
            }
            return exists;
        }
    }
}
