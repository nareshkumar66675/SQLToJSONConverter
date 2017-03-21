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

        public AuthFacade()
        {
            _authPreRequisites.AddRange(new LegacyFacade().PreRequisites);
            _authPreRequisites.Add(new ExecuteScriptPreRequisite("MigrationTables"));
        }
        public override string ConnectionString
        {
            get
            {
                return ConnectionStrings.AuthConnectionString;
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
