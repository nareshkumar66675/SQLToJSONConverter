using static Migration.Common.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Migration.PreRequisite.PreRequisites;

namespace Migration.PreRequisite.Facades
{
    public class AssetFacade : AbstractFacade
    {
        private List<IPreRequisite> _assetPreRequisites = new List<IPreRequisite>();
        private string _connectionString = ConnectionStrings.AuthConnectionString;
        public AssetFacade()
        {
            _assetPreRequisites.Add(new ExecuteScriptPreRequisite("NewMigrationTables", _connectionString));
            _assetPreRequisites.Add(new InsertCompDefinitionIdPreRequisite(_connectionString));
        }
        public override FacadeType Type
        {
            get
            {
                return FacadeType.Asset;
            }
        }

        public override List<IPreRequisite> PreRequisites
        {
            get
            {
                return _assetPreRequisites;
            }
        }
    }
}
