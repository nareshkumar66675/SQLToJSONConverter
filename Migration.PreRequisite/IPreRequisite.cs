using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.PreRequisite
{
    public interface IPreRequisite
    {
        string Name { get; }
        bool Execute(string connectionString);
    }
}
