using Migration.PreRequisite.PreRequisites;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.PreRequisite.Facades
{
    /// <summary>
    /// Report Facade - Executes PreRequistes for Report 
    /// </summary>
    public class ReportFacade:AbstractPreRequisite
    {
        private List<IPreRequisite> _reportPreRequisites = new List<IPreRequisite>();
        private string _connectionString = ConnectionStrings.GetConnectionString(Common.GroupType.REPORT);
        public ReportFacade()
        {
            _reportPreRequisites.Add(new ExecuteScriptPreRequisite("NewMigrationTables", _connectionString));
            _reportPreRequisites.Add(new ExecuteScriptPreRequisite("ReportTruncateTables", _connectionString));
        }
        public override FacadeType Type => FacadeType.Report;

        public override List<IPreRequisite> PreRequisites => _reportPreRequisites;
    }
}
