using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.ProcessQueue
{
    public static class ProcessQueue
    {
        /// <summary>
        /// List of Queued Process to execute
        /// Max Queue Size Depends on <see cref="AppSettings.MaxQueueSize"/>
        /// </summary>
        public static BlockingCollection<ProcessItem> Processes { get; set; }
        /// <summary>
        /// Initilaizes Process Queue.
        /// Max Queue Size Depends on <see cref="AppSettings.MaxQueueSize"/>
        /// </summary>
        static ProcessQueue()
        {
            Processes = new BlockingCollection<ProcessItem>(AppSettings.MaxQueueSize);
        }
    }
}
