using Migration.Configuration;
using Migration.PreRequisite.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.PreRequisite.PreRequisites
{
    class InsertNumberMasterPreRequisite : IPreRequisite
    {
        private readonly string _name = string.Empty;
        private readonly string _connetionString = string.Empty;
        public string Name => _name;
        public InsertNumberMasterPreRequisite(string name,string connectionString)
        {
            _name = name;
            _connetionString = connectionString;
        }
        public bool Execute()
        {
            //Get Number Master Max Ids from Legacy DB
            var updateScript = SqlOperation.GetScriptsFromQuery(ConnectionStrings.LegacyConnectionString, Configurator.GetScriptFile(_name));

            //Execute the Scripts
            return SqlOperation.ExecuteQuery(_connetionString, updateScript);
        }
    }
}
