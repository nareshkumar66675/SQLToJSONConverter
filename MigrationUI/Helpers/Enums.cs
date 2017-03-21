using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MigrationTool.Helpers
{
    public enum AuthenticationType
    {
        [Description("SQL Server Authentication")]
        SQLServer,
        [Description("Windows Authentication")]
        Windows
    }
}
