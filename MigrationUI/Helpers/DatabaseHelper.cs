﻿using Migration.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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

                using (SqlCommand cmd = new SqlCommand("SELECT name from sys.databases", con))
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
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                string query = @"select Distinct SiteID from[Migration].[SiteGroup] grp 
                                LEFT JOIN[Migration].[Report] rpt on grp.SiteGroupID = rpt.SiteGroupID and rpt.[Status] = 'Success'";
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
            string query = string.Empty;
            string conString = string.Empty;
            if (group == GroupType.AUTH)
            {
                query = "SELECT DISTINCT Component_Name from Migration.Report where Status = 'Success'";
                conString = Common.ConnectionStrings.AuthConnectionString;
            }
            else if (group == GroupType.ASSET)
            {
                query = @"SELECT DISTINCT Component_Name from Migration.Report rpt
                                Inner join Migration.SiteGroup grp on rpt.SiteGroupID=grp.SiteGroupID
                                where Status='Success'";
                conString = Common.ConnectionStrings.AssetConnectionString;
                if (Sites != null && Sites.Count > 0)
                    query += query + " and SiteID in (" + string.Join(",", Sites) + ")";
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
                            completedComp.Add(dr[0].ToString());
                        }
                    }
                }
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
