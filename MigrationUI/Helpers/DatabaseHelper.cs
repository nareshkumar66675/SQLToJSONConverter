﻿using Migration.Common;
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
        public static Dictionary<string, string> GetAllSitesFromLegacy()
        {
            Dictionary<string, string> SiteList = new Dictionary<string, string>();
            using (SqlConnection con = new SqlConnection(ConnectionStrings.LegacyConnectionString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand("SELECT SITE_NUMBER,Site_Long_Name FROM GAM.SITE order by Site_Long_Name", con))
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

        internal static DataTable GetReportSummary(GroupType group)
        {
            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("Group"));
            table.Columns.Add(new DataColumn("DisplayName"));
            table.Columns.Add(new DataColumn("Site Count"));
            table.Columns.Add(new DataColumn("Legacy Records"));
            table.Columns.Add(new DataColumn("Unique Records"));
            table.Columns.Add(new DataColumn("Inserted Records"));

            string query = @"SELECT Component_Name,
                                            MAX(SiteCount) as SiteCount,
                                            SUM (Tot_Rcrds_InLegacy) as Legacy ,
                                            SUM(Tot_Unique_RcrdsInLegacy) as [Unique],
                                            SUM(Inserted_Rcrds_InNew) as [InsertedRcrds]
                             FROM Migration.Report LEFT JOIN (SELECT SiteGroupID, COUNT(SiteID) as SiteCount FROM Migration.SiteGroup GROUP BY SiteGroupID) as Sg
							 on Report.SiteGroupID=sg.SiteGroupID
                             WHERE [Status]='Success'
                             GROUP BY Component_Name,Report.SiteGroupID";

            if (!string.IsNullOrWhiteSpace(ConnectionStrings.GetConnectionString(group)))
            {
                using (SqlConnection con = new SqlConnection(ConnectionStrings.GetConnectionString(group)))
                {
                    con.Open();

                    using (SqlCommand cmd = new SqlCommand(query, con))
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
            catch (SqlException)
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
    }
}
