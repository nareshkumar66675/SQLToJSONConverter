using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Common
{
    public static class Common
    {
        /// <summary>
        /// Connection Strings
        /// </summary>
        public static class ConnectionStrings
        {
            /// <summary>
            /// Legacy Connection String
            /// </summary>
            public static string LegacyConnectionString { get; set; } = string.Empty;
            /// <summary>
            /// Auth Connection String
            /// </summary>
            private static string AuthConnectionString { get; set; } = string.Empty;
            /// <summary>
            /// Asset Connection String
            /// </summary>
            private static string AssetConnectionString { get; set; } = string.Empty;
            /// <summary>
            /// Report Connection String
            /// </summary>
            private static string ReportConnectionString { get; set; } = string.Empty;
            /// <summary>
            /// Retrieves Connection String based on Group Type
            /// </summary>
            /// <param name="group">Group Type</param>
            /// <returns>Connection String</returns>
            public static string GetConnectionString(GroupType group)
            {
                switch (group)
                {
                    case GroupType.AUTH:
                        return AuthConnectionString;
                    case GroupType.ASSET:
                        return AssetConnectionString;
                    case GroupType.REPORT:
                        return ReportConnectionString;
                    case GroupType.HISTORY:
                        return ReportConnectionString;
                    default:
                        return string.Empty;
                }
            }
            /// <summary>
            /// Sets Values to Connection String
            /// </summary>
            /// <param name="group"></param>
            /// <param name="connectionString"></param>
            public static void SetConnectionString(GroupType group,string connectionString)
            {
                switch (group)
                {
                    case GroupType.AUTH:
                        AuthConnectionString = connectionString;
                        break;
                    case GroupType.ASSET:
                        AssetConnectionString = connectionString;
                        break;
                    case GroupType.REPORT:
                        ReportConnectionString = connectionString;
                        break;
                    case GroupType.HISTORY:
                        ReportConnectionString = connectionString;
                        break;
                }
            }
        }
        /// <summary>
        /// Common Constants
        /// </summary>
        public static class Constants
        {
            public const string DEFAULTGENERATE = "DEFAULT";
            public const string DEFAULTWTPARAMSGENERATE = "DEFAULTWITHPARAMS";
            public const string AUTHDATAGENERATE = "AUTHDATA";
            public const string ASSETDATAGENERATE = "ASSETDATA";
            public const string HISTORYDATAGENERATE = "HISTORYDATA";
            public const string DEFAULTPERSIST = "DEFAULT";
        }
        /// <summary>
        /// App Settings
        /// </summary>
        public static class AppSettings
        {
            public static int BulkCopyBatchSize
            {
                get
                {
                    int batchSize ;
                    return int.TryParse(ConfigurationManager.AppSettings.Get("BulkCopySize"), out batchSize) ? batchSize : 5000;
                }
                private set { }
            }
            public static string LogFileName
            {
                get
                {
                    return string.IsNullOrEmpty(ConfigurationManager.AppSettings.Get("LogFileName")) ? "MigrateLog" : ConfigurationManager.AppSettings.Get("LogFileName");
                }
                private set { }
            }
            public static string LogFileTimeStampPattern
            {
                get
                {
                    return string.IsNullOrEmpty(ConfigurationManager.AppSettings.Get("LogFileTimeStampPattern")) ? "yyyyMMdd_HHmmss" : ConfigurationManager.AppSettings.Get("LogFileTimeStampPattern");
                }
                private set { }
            }
            public static string LogFilePath
            {
                get
                {
                    var logFilePath = ConfigurationManager.AppSettings.Get("LogFilePath");
                    if (string.IsNullOrWhiteSpace(logFilePath))
                        return Directory.GetCurrentDirectory();
                    else
                    {
                        if (Directory.Exists(logFilePath))
                            return logFilePath;
                        else
                        {
                            try
                            {
                                Directory.CreateDirectory(logFilePath);
                            }
                            catch (Exception)
                            {
                                return Directory.GetCurrentDirectory();
                            }
                            return logFilePath;
                        }
                    }
                }
                private set { }
            }
            public static int MaxQueueSize
            {
                get
                {
                    int queueSize;
                    return int.TryParse(ConfigurationManager.AppSettings.Get("MaxQueueSize"), out queueSize) ? queueSize : 3;
                }
                private set { }
            }
            public static bool IsReportEnabled
            {
                get
                {
                    bool isReportEnabled;
                    return bool.TryParse(ConfigurationManager.AppSettings.Get("IsReportEnabled"), out isReportEnabled) ? isReportEnabled : false;
                }
                private set { }
            }
            public static string LegacyDBCheck
            {
                get
                {
                    return string.IsNullOrEmpty(ConfigurationManager.AppSettings.Get("LegacyDBCheck")) ? "GAM.ASSET" : ConfigurationManager.AppSettings.Get("LegacyDBCheck");
                }
                private set { }
            }
            public static string AuthDBCheck
            {
                get
                {
                    return string.IsNullOrEmpty(ConfigurationManager.AppSettings.Get("AuthDBCheck")) ? "Site.Site" : ConfigurationManager.AppSettings.Get("AuthDBCheck");
                }
                private set { }
            }
            public static string AssetDBCheck
            {
                get
                {
                    return string.IsNullOrEmpty(ConfigurationManager.AppSettings.Get("AssetDBCheck")) ? "DataManagement.Asset" : ConfigurationManager.AppSettings.Get("AssetDBCheck");
                }
                private set { }
            }
            public static string ReportDBCheck
            {
                get
                {
                    return string.IsNullOrEmpty(ConfigurationManager.AppSettings.Get("ReportDBCheck")) ? "Report.Asset" : ConfigurationManager.AppSettings.Get("ReportDBCheck");
                }
                private set { }
            }
            public static bool RunPreRequisites
            {
                get
                {
                    bool runPreRequisites;
                    return bool.TryParse(ConfigurationManager.AppSettings.Get("RunPreRequisites"), out runPreRequisites) ? runPreRequisites : false;
                }
                private set { }
            }
            public static List<string> Cultures
            {
                get
                {
                    var culture=ConfigurationManager.AppSettings.Get("Cultures").Split(';').ToList();
                    return culture != null && culture.Count() > 0 ? culture : new List<string> { "en-AU"};
                }
                private set { }
            }
            public static int SqlCommandTimeout
            {
                get
                {
                    int sqlCommandTimeout;
                    return int.TryParse(ConfigurationManager.AppSettings.Get("SqlCommandTimeout"), out sqlCommandTimeout) ? sqlCommandTimeout : 500;
                }
                private set { }
            }
            public static bool IsReportCheck
            {
                get
                {
                    bool isReportCheck;
                    return bool.TryParse(ConfigurationManager.AppSettings.Get("IsReportCheck"), out isReportCheck) ? isReportCheck : false;
                }
                private set { }
            }
        }
        /// <summary>
        /// Common Queries
        /// </summary>
        public static class Queries
        {
            public static string ReportInsertOrUpdate
            {
                get
                {
                    return @"IF EXISTS(SELECT 1 FROM [Migration].[Report] WHERE [Component_Name] = @Name)
                                BEGIN
                                    UPDATE [Migration].[Report] SET [Tot_Rcrds_InLegacy]=@TotRecords,[Tot_Unique_RcrdsInLegacy]=@TotUniqRecords,
                                                                    [Start_Time]=@StartTime,[End_Time]=@EndTime,[Status]=@Status
	                                        WHERE [Component_Name]=@Name
                                END
                             ELSE
                                BEGIN
                                    INSERT INTO [Migration].[Report] ([Component_Name],[Tot_Rcrds_InLegacy],[Tot_Unique_RcrdsInLegacy],[Start_Time],[End_Time],[Status]) 
                                                VALUES (@Name,@TotRecords,@TotUniqRecords,@StartTime,@EndTime,@Status)
                                END";
                }
                private set { }
            }
            public static string ReportInsert
            {
                get
                {
                    return @"INSERT INTO [Migration].[Report] ([Component_Name],[SiteGroupID],[Tot_Rcrds_InLegacy],[Tot_Unique_RcrdsInLegacy],[Start_Time],[End_Time],[Status]) 
                                                VALUES (@Name,@SiteGrpID,@TotRecords,@TotUniqRecords,@StartTime,@EndTime,@Status)";
                }
                private set { }
            }
            public static string ReportUpdate
            {
                get
                {
                    return @"UPDATE [Migration].[Report] SET [Inserted_Rcrds_InNew]=@InsrtdRcrds,[End_Time]=@EndTime,[Status]=@Status WHERE [Component_Name]=@Name and [Status] ='Running'";
                }
                private set { }
            }
            public static string GetSiteGroupMaxID
            {
                get
                {
                    return "SELECT MAX(SiteGroupID) FROM Migration.SiteGroup";
                }
                private set { }
            }
            public static string SiteGroupInsert
            {
                get
                {
                    return "INSERT INTO Migration.SiteGroup (SiteGroupID,SiteID,SiteName) VALUES({0},{1},'{2}');";
                }
                private set { }
            }
            public static string GetSiteDetails
            {
                get
                {
                    return "SELECT SITE_NUMBER,SITE_LONG_NAME FROM [MIGRATION].[VIEW_SITE_INFO] WHERE SITE_NUMBER in ({0})";
                }
                private set { }
            }
            public static string GetCompletedPreRequisites
            {
                get
                {
                    return "SELECT PreRequisiteName FROM [Migration].[PreRequisite] WHERE Status='Success'";
                }
                private set { }
            }      
            public static string InsertPreRequisites
            {
                get
                {
                    return "INSERT INTO[Migration].[PreRequisite] (PreRequisiteName,Status,CreatedTime) VALUES(@Name, @Status, GETDATE())";
                }
                private set { }
            }
            public static string PreRequisiteTableName
            {
                get
                {
                    return "Migration.PreRequisite";
                }
                private set { }
            }
        }
    }
}
