using Migration.PreRequisite.PreRequisites;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.PreRequisite.Facades
{
    class LegacyFacade : AbstractFacade
    {
        private List<IPreRequisite> _legacyPreRequisites = new List<IPreRequisite>();

        public LegacyFacade()
        {
            _legacyPreRequisites.Add(new ExecuteScriptPreRequisite("LegacyMigrationTables"));
            _legacyPreRequisites.Add(new ExecuteScriptPreRequisite("AstDfnIdInsert"));
            _legacyPreRequisites.Add(new ExecuteScriptPreRequisite("LegacyViews"));
        }

        public override string ConnectionString
        {
            get
            {
                return ConnectionStrings.LegacyConnectionString;
            }
        }

        public override List<IPreRequisite> PreRequisites
        {
            get
            {
                return _legacyPreRequisites;
            }
        }
    }
}
