using Migration.PreRequisite.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.PreRequisite.PreRequisites
{
    class UpdateGeoDataPreRequisite:IPreRequisite
    {
        private const string _name = "UpdateGeoData";
        private readonly string _connetionString;
        public string Name => _name;
        public UpdateGeoDataPreRequisite(string connectionString)
        {
            _connetionString = connectionString;
        }
        public bool Execute()
        {
            //Update Geo Data
            return SqlOperation.UpdateGeoData(_connetionString);
        }
    }
}
