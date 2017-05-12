using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.ProcessQueue
{
    /// <summary>
    /// Status Of Process
    /// </summary>
    public enum Status
    {
        /// <summary>
        /// Process not started
        /// </summary>
        [Description("Not Started")]
        NotStarted,
        /// <summary>
        /// Process Started
        /// </summary>
        [Description("Started")]
        Started,
        /// <summary>
        /// Process Running
        /// </summary>
        [Description("Running")]
        Running,
        /// <summary>
        /// Process Completed Successfully
        /// </summary>
        [Description("Success")]
        Success,
        /// <summary>
        /// Process Completed with Errors
        /// </summary>
        [Description("Failed")]
        Failed
    }
    /// <summary>
    /// Defines the type of Items
    /// </summary>
    public enum ItemsType
    {
        /// <summary>
        /// Full Data
        /// </summary>
        Full,
        /// <summary>
        /// Partial Data
        /// </summary>
        Partial,
        /// <summary>
        /// End or last chunk of partail Data
        /// </summary>
        PartialEnd
    }
    /// <summary>
    /// Process Status
    /// </summary>
    public class ProcessStatus
    {
        public ProcessStatus(string componentName,int percentCompleted,Status status)
        {
            this.ComponentName = componentName;
            this.PercentCompleted = percentCompleted;
            this.Status = status;
        }

        private int _percentCompleted;
        /// <summary>
        /// Component Name
        /// </summary>
        public string ComponentName { get; set; }
        /// <summary>
        /// Current Status
        /// </summary>
        public Status Status { get; set; } = Status.NotStarted;
        /// <summary>
        /// Percentage Completed
        /// </summary>
        public int PercentCompleted {
            get
            {
                return _percentCompleted;
            }
            set
            {
                if (value < 0)
                    _percentCompleted = 0;
                else if (value > 100)
                    _percentCompleted = 100;
                else
                    _percentCompleted = value;
            }
        }
    }
}
