using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.PreRequisite
{
    /// <summary>
    /// PreRequistes Implementation
    /// </summary>
    public interface IPreRequisite
    {
        /// <summary>
        /// Unique PreRequisiteName
        /// </summary>
        string Name { get; }
        /// <summary>
        /// Executes the PreRequsite
        /// </summary>
        /// <returns>True, if Success else False</returns>
        bool Execute();
    }
}
