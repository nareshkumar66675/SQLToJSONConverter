using Migration.PreRequisite.PreRequisites;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.PreRequisite.Facades
{
    public class AuthFacade:AbstractFacade
    {
        private List<IPreRequisite> _authPreRequisites = new List<IPreRequisite>();
        private string _connectionString = ConnectionStrings.AuthConnectionString;
        public AuthFacade()
        {
            _authPreRequisites.Add(new ExecuteScriptPreRequisite("NewMigrationTables", _connectionString));
            _authPreRequisites.AddRange(new LegacyFacade().PreRequisites);
            _authPreRequisites.Add(new ExecuteScriptPreRequisite("AuthStaticData", _connectionString));
        }
        public override FacadeType Type
        {
            get
            {
                return FacadeType.Auth;
            }
        }
        public override List<IPreRequisite> PreRequisites
        {
            get
            {
                return _authPreRequisites;
            }
        }
    }
}
