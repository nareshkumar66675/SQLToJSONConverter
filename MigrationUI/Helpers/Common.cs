using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MigrationTool.Helpers
{
    public enum AuthenticationType
    {
        [Description("SQL Server Authentication")]
        SQLServer,
        [Description("Windows Authentication")]
        Windows
    }

    public static class Queries
    {
        public const string SITEGRPTABNAME = @"Migration.SiteGroup";
        public const string GETALLACTIVEDBS = @"SELECT NAME FROM sys.databases WHERE state_desc<>'OFFLINE'";
        public const string GETALLACTIVESITES = @"SELECT SITE_NUMBER, Site_Long_Name FROM GAM.SITE ORDER BY Site_Long_Name";
        public const string CHECKTABLEEXISTS = @"SELECT CASE WHEN EXISTS((SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=@Schema AND TABLE_NAME = @TableName)) THEN 1 ELSE 0 END";
        public const string GETCOMPITEMSWITHOUTSITE = @"SELECT DISTINCT Component_Name from Migration.Report where Status = 'Success'";
        public const string GETMIGRATEDSITES = @"SELECT Distinct SiteID FROM [Migration].[SiteGroup] grp 
                                                 LEFT JOIN[Migration].[Report] rpt on grp.SiteGroupID = rpt.SiteGroupID WHERE rpt.[Status] = 'Success'";
        public const string GETCOMPITEMSWITHSITE = @"SELECT DISTINCT Component_Name FROM Migration.Report rpt
                                                     LEFT JOIN Migration.SiteGroup grp ON rpt.SiteGroupID=grp.SiteGroupID 
                                                     WHERE Status='Success' ";
        public const string GETREPORTSUMMARY = @"SELECT Component_Name,
                                                        MAX(SiteCount) as SiteCount,
                                                        SUM (Tot_Rcrds_InLegacy) as Legacy ,
                                                        SUM(Tot_Unique_RcrdsInLegacy) as [Unique],
                                                        SUM(Inserted_Rcrds_InNew) as [InsertedRcrds]
                                                 FROM Migration.Report LEFT JOIN (SELECT SiteGroupID, COUNT(SiteID) as SiteCount FROM Migration.SiteGroup GROUP BY SiteGroupID) as Sg
							                     on Report.SiteGroupID=sg.SiteGroupID
                                                 WHERE [Status]='Success'
                                                 GROUP BY Component_Name,Report.SiteGroupID";
    }
}
