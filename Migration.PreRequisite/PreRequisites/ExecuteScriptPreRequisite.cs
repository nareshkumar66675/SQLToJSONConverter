using Migration.Configuration;
using Migration.PreRequisite.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.PreRequisite.PreRequisites
{
    public class ExecuteScriptPreRequisite : IPreRequisite
    {
        private readonly string _name = string.Empty;
        private readonly string _connectionString = string.Empty;
        public ExecuteScriptPreRequisite(string name,string connString)
        {
            _name = name;
            _connectionString = connString;
        }
        public string Name
        {
            get
            {
                return _name;
            }
        }
        public bool Execute()
        {
            string sqlQuery = Configurator.GetScriptFile(_name);
            return SqlOperation.ExecuteQuery(_connectionString, sqlQuery);
        }
    }
}
