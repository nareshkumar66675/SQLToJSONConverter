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
        public static AbstractPreRequisite GetPreRequistes(GroupType grpType)
        {
            switch (grpType)
            {
                case GroupType.AUTH:
                    return new AuthFacade();
                case GroupType.ASSET:
                    return new AssetFacade();
                case GroupType.SEARCH:
                    return null;
                default:
                    return null;
            }
        }
    }
}
