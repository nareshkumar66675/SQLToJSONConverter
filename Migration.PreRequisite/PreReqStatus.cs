using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.PreRequisite
{
    public enum PreReqStatus
    {
        [Description("Not Needed")]
        NotNeeded,
        [Description("Completed")]
        Completed,
        [Description("Failed")]
        Failed
    }
    public class PreReqProgress
    {
        public int TotalCount { get; set; }
        public List<PreReqItem> Completed { get; set; }
        public int CompletedCount { get; set; }
    }
    public class PreReqItem
    {
        public PreReqItem(string name, PreReqStatus status,int order)
        {
            this.Name = name;
            this.Status = status;
            this.Order = order;
        }
        public string Name { get; set; }
        public PreReqStatus Status { get; set; }
        public int Order { get; set; }
    }
}
