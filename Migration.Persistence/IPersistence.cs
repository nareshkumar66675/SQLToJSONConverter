using Migration.Configuration.ConfigObject;
using Migration.ProcessQueue;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Persistence
{
    public interface IPersistence
    {
        /// <summary>
        /// Inserts Data
        /// </summary>
        /// <param name="item">Process Item for processing</param>
        /// <returns>True, is success else False</returns>
        bool Insert(ProcessItem item);
    }
}
