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
        public static class ConnectionStrings
        {
            public static string AuthConnectionString = @"Data Source=ws-in1060\SQLServer;Integrated Security=true;Initial Catalog=Auth";
            public static string AssetConnectionString = @"Data Source=ws-in1060\SQLServer;Integrated Security=True;Initial Catalog=Asset";
            //public static string SourceConnectionString = "Data Source=10.2.108.21\\MSSQLSERVER2K12;Integrated Security=False;User ID=sa;Password=abc@123;Initial Catalog=AM140NEW";
            //public static string SourceConnectionString = "Data Source=10.2.108.169;Integrated Security=False;User ID=sa;Password=abc@123;Initial Catalog=AM140NEW";
            public static string LegacyConnectionString = @"Data Source=ws-in1060\SQLServer;Integrated Security=True;Initial Catalog=Migration";
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
                        case GroupType.SEARCH:
                            return "";
                        default:
                            return "";
                    }
                }
        }

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
                    return !Directory.Exists(ConfigurationManager.AppSettings.Get("LogFilePath")) ? Directory.GetCurrentDirectory() : ConfigurationManager.AppSettings.Get("LogFilePath");
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

        }

        public static class Queries
        {
            public static string ReportInsert
            {
                get
                {
                    return @"INSERT INTO [Migration].[Report] ([Component_Name],[Tot_Rcrds_InLegacy],[Tot_Unique_RcrdsInLegacy],[Start_Time],[Status]) 
                             VALUES (@Name,@TotRecords,@TotUniqRecords,@StartTime,@Status)";
                }
                private set { }
            }
            public static string ReportUpdate
            {
                get
                {
                    return @"UPDATE [Migration].[Report] SET [Inserted_Rcrds_InNew]=@InsrtdRcrds,[End_Time]=@EndTime,[Status]=@Status WHERE [Component_Name]=@Name";
                }
                private set { }
            }
        }
    }
}
