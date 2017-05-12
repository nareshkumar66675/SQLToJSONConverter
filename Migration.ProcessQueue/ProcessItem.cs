using Migration.Configuration.ConfigObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.ProcessQueue
{
    public class ProcessItem
    {
        public ProcessItem(Component _component, List<object> _items)
        {
            this.Component = _component;
            this.Items = _items;
        }
        public ProcessItem(Component _component, List<object> _items,ItemsType _type)
        {
            this.Component = _component;
            this.Items = _items;
            this.Type = _type;
        }
        /// <summary>
        /// Defines the Item Type.
        /// Default Type is <see cref="ItemsType.Full"/>
        /// </summary>
        public ItemsType Type { get; set; } = ItemsType.Full;
        /// <summary>
        /// Component Information related data
        /// </summary>
        public Component Component { get; set; }
        /// <summary>
        /// List of Data
        /// </summary>
        public List<object> Items { get; set; }
    }
}
