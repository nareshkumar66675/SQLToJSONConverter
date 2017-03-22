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
        private string _connectionString = ConnectionStrings.LegacyConnectionString;
        public LegacyFacade()
        {
            _legacyPreRequisites.Add(new ExecuteScriptPreRequisite("LegacyMigrationTables", _connectionString));
            _legacyPreRequisites.Add(new ExecuteScriptPreRequisite("AssetDefinitionParseSP", _connectionString));
            _legacyPreRequisites.Add(new ExecuteScriptPreRequisite("LegacyViews", _connectionString));
        }

        public override FacadeType Type
        {
            get
            {
                return FacadeType.Legacy;
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
