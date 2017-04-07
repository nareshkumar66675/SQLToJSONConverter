using Migration.Common;
using Migration.PreRequisite.Facades;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.PreRequisite
{
    public static class PreRequisiteFactory
    {
        /// <summary>
        /// Retrieves PreRequisite Executor Based on Group Type
        /// </summary>
        /// <param name="grpType">Group Type</param>
        /// <returns>PreRequisite Executor</returns>
        public static AbstractPreRequisite GetPreRequistes(GroupType grpType)
        {
            Logger.Instance.LogInfo($"PreRequisites for Group - {grpType.ToString()}");

            switch (grpType)
            {
                case GroupType.AUTH:
                    return new AuthFacade();
                case GroupType.ASSET:
                    return new AssetFacade();
                case GroupType.REPORT:
                    return new ReportFacade();
                default:
                    return null;
            }
        }
    }
}
