using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;
using Migration.Common;

namespace Migration.Configuration.ConfigObject
{
    /// <summary>
    /// Component Details
    /// </summary>
    [XmlRoot(ElementName = "Component")]
    public class Component
    {
        /// <summary>
        /// Unique Component Name
        /// </summary>
        [XmlAttribute(AttributeName = "Name")]
        public string Name { get; set; }
        /// <summary>
        /// Component display name
        /// </summary>
        [XmlAttribute(AttributeName = "DisplayName")]
        public string DisplayName { get; set; }
        /// <summary>
        /// Fully Qualified Domain Name
        /// </summary>
        [XmlAttribute(AttributeName = "DomainType")]
        public string DomainType { get; set; }
        /// <summary>
        /// Data Generation Type
        /// Default Value - Default
        /// </summary>
        [XmlAttribute(AttributeName = "GenerateType")]
        public string GenerateType { get; set; }
        /// <summary>
        /// Data Persistence Type
        /// Default Value - Default
        /// </summary>
        [XmlAttribute(AttributeName = "PersistType")]
        public string PersistType { get; set; }
        /// <summary>
        /// Group Name
        /// </summary>
        [XmlIgnore]
        public GroupType GroupName { get; set; }
    }
    /// <summary>
    /// Group Details
    /// </summary>
    [XmlRoot(ElementName = "Group")]
    public class Group
    {
        public Group() { }
        public Group(List<Component> Component, GroupType Name)
        {
            this.Component = Component;
            this.Name = Name;
        }
        /// <summary>
        /// List of Components
        /// </summary>
        [XmlElement(ElementName = "Component")]
        public List<Component> Component { get; set; }
        /// <summary>
        /// Group Type
        /// </summary>
        [XmlAttribute(AttributeName = "Name")]
        public GroupType Name { get; set; }
    }
    /// <summary>
    /// Components Configuration
    /// </summary>
    [XmlRoot(ElementName = "ComponentConfig")]
    public class Components
    {
        /// <summary>
        /// List Of Groups
        /// </summary>
        [XmlElement(ElementName = "Group")]
        public List<Group> Group { get; set; }
    }
}
