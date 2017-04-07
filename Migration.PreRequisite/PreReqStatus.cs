using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.PreRequisite
{
    /// <summary>
    /// Status of the PreRequisites
    /// </summary>
    public enum PreReqStatus
    {
        /// <summary>
        /// Not Necessary or Did't run
        /// </summary>
        [Description("Not Needed")]
        NotNeeded,
        /// <summary>
        /// Completed Successfully
        /// </summary>
        [Description("Success")]
        Success,
        /// <summary>
        /// Failed with Errors
        /// </summary>
        [Description("Failed")]
        Failed
    }
    /// <summary>
    /// PreRequisite Progress
    /// </summary>
    public class PreReqProgress
    {
        public PreReqProgress(int totalCount, int completedCount, List<PreReqItem> completed)
        {
            this.TotalCount = totalCount;
            this.CompletedCount = completedCount;
            this.Completed = completed;
        }
        /// <summary>
        /// Total PreRequiste Count
        /// </summary>
        public int TotalCount { get; set; }
        /// <summary>
        /// Total Completed PreRequisite Items
        /// </summary>
        public List<PreReqItem> Completed { get; set; }
        /// <summary>
        /// Completed PreRequsite Count
        /// </summary>
        public int CompletedCount { get; set; }
    }
    /// <summary>
    /// PreRequisite Item
    /// </summary>
    public class PreReqItem
    {
        public PreReqItem(string name, PreReqStatus status,int order)
        {
            this.Name = name;
            this.Status = status;
            this.Order = order;
        }
        /// <summary>
        /// PreRequisite NAme
        /// </summary>
        public string Name { get; set; }
        /// <summary>
        /// PreRequisite Status
        /// </summary>
        public PreReqStatus Status { get; set; }
        /// <summary>
        /// Order of Execution
        /// </summary>
        public int Order { get; set; }
    }
}
