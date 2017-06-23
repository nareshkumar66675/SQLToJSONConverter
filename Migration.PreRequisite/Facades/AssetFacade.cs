using static Migration.Common.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Migration.PreRequisite.PreRequisites;

namespace Migration.PreRequisite.Facades
{
    /// <summary>
    /// Asset Facade - Executes PreRequistes for Asset 
    /// </summary>
    public class AssetFacade : AbstractPreRequisite
    {
        private List<IPreRequisite> _assetPreRequisites = new List<IPreRequisite>();
        private string _connectionString = ConnectionStrings.AssetConnectionString;
        public AssetFacade()
        {
            _assetPreRequisites.Add(new ExecuteScriptPreRequisite("NewMigrationTables", _connectionString));
            _assetPreRequisites.Add(new ExecuteScriptPreRequisite("AssetDefault", _connectionString));
            _assetPreRequisites.Add(new ExecuteScriptPreRequisite("CountryGeoData", _connectionString));
            _assetPreRequisites.Add(new InsertCompDefinitionIdPreRequisite(_connectionString));
            _assetPreRequisites.Add(new ExecuteScriptPreRequisite("OptionOrderUpdate", ConnectionStrings.LegacyConnectionString));
            _assetPreRequisites.Add(new InsertCustomAssetIDPreRequisite(_connectionString));
            _assetPreRequisites.Add(new InsertNumberMasterPreRequisite("AssetNumberMasterInsert", _connectionString));
            _assetPreRequisites.Add(new ExecuteScriptPreRequisite("UpdateCustomID", _connectionString));
            _assetPreRequisites.Add(new UpdateGeoDataPreRequisite(_connectionString));
        }
        public override FacadeType Type => FacadeType.Asset;
        public override List<IPreRequisite> PreRequisites => _assetPreRequisites;
    }
}
