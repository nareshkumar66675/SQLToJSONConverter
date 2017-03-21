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
        public ExecuteScriptPreRequisite(string name)
        {
            _name = name;
        }
        private string _name = string.Empty;
        public string Name
        {
            get
            {
                return _name;
            }
        }
        public bool Execute(string connectionString)
        {
            string sqlQuery = Configurator.GetScriptFile(_name);
            return SqlOperation.ExecuteQuery(connectionString, sqlQuery);
        }
    }
}
