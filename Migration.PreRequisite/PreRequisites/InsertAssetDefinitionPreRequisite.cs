using Migration.Configuration;
using Migration.PreRequisite.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.PreRequisite.PreRequisites
{
    public class InsertAssetDefinitionPreRequisite : IPreRequisite
    {
        private const string _name = "InsertAssetDefinition";
        private readonly string _connetionString = string.Empty;
        public string Name => _name;
        public InsertAssetDefinitionPreRequisite(string connectionString)
        {
            _connetionString = connectionString;
        }
        public bool Execute()
        {
            //Get Script File
            string sqlQuery = Configurator.GetScriptFile(_name);

            return SqlOperation.InsertAssetDefinition(_connetionString,sqlQuery);
        }
    }
}
