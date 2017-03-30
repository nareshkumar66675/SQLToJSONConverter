using Migration.PreRequisite.PreRequisites;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.PreRequisite.Facades
{
    class ReportFacade:AbstractPreRequisite
    {
        private List<IPreRequisite> _historyPreRequisites = new List<IPreRequisite>();
        private string _connectionString = ConnectionStrings.ReportConnectionString;
        public ReportFacade()
        {
            _historyPreRequisites.Add(new ExecuteScriptPreRequisite("NewMigrationTables", _connectionString));
            _historyPreRequisites.Add(new ExecuteScriptPreRequisite("ReportTruncateTables", _connectionString));
        }
        public override FacadeType Type
        {
            get
            {
                return FacadeType.Report;
            }
        }

        public override List<IPreRequisite> PreRequisites
        {
            get
            {
                return _historyPreRequisites;
            }
        }
    }
}
