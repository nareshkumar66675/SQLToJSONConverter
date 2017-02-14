using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.ProcessQueue
{
    public enum Status
    {
        [Description("Not Started")]
        NotStarted,
        Started,
        Running,
        Success,
        Failed
    }
    public class ProcessStatus
    {
        public ProcessStatus(string componentName,int percentCompleted,Status status)
        {
            this.ComponentName = componentName;
            this.PercentCompleted = percentCompleted;
            this.Status = status;
            this.ProcessDetail = new ProcessReport();
        }

        private int _percentCompleted;
        public string ComponentName { get; set; }
        public Status Status { get; set; } = Status.NotStarted;
        public ProcessReport ProcessDetail { get; set; }
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
    public class ProcessReport
    {
        public long TotalRecordsInSource { get; set; }
        public long TotalUniqueRecordsInSource { get; set; }
        public long InsertedRecordsInDestination { get; set; }
    }
}
