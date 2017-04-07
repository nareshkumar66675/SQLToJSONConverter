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
    class UMDataRetrievalPreRequisite : IPreRequisite
    {
        private const string _name = "UMDataRetrieval";
        public string Name
        {
            get
            {
                return _name;
            }
        }

        public bool Execute()
        {
            //Get SQL Scripts From User Matrix Data
            var updateScript = SqlOperation.GetDataFromUserMatrix(Configurator.GetScriptFile(_name));

            //Execute the Scripts
            return SqlOperation.ExecuteQuery(ConnectionStrings.LegacyConnectionString, updateScript);
        }
    }
}
