﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.PreRequisite.Helpers
{
    public static class Queries
    {
        public const string GETALLACTIVESITENO = @"SELECT SITE_NUMBER FROM [MIGRATION].[VIEW_SITE_INFO]";
        public const string SPUPDATEGEODATA = @"COMMON.P_GETDASHBOARDSITEINFO";
        public const string TBLASSETDFN = @"[MIGRATION].[ASSET_TYPE_DEFN]";
        public const string SPASSETDFN = @"MIGRATION.P_ASSET_DEFINITION";
        public const string TBLCUSTOMID = @"[IDGEN].[CustomID_VALUES]";
        public const string SPDASHBAORDCOUNT = @"MIGRATION.P_GET_DASHBOARD_COUNT";
        public const string CHECKTABLEEXISTS = @"SELECT CASE WHEN EXISTS((SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=@Schema AND TABLE_NAME = @TableName)) THEN 1 ELSE 0 END";
        public const string CHECKASSETDFN = @"IF EXISTS((SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='Migration' AND TABLE_NAME = 'ASSET_TYPE_DEFN')) BEGIN
                                                 SELECT CASE WHEN COUNT(ID) > 0 THEN 0 ELSE 1 END from MIGRATION.ASSET_TYPE_DEFN END
                                                 ELSE BEGIN SELECT - 1 END";
    }
}
