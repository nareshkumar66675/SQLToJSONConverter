using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;
using Migration.Common;

namespace Migration.Configuration.ConfigObject
{
    [XmlRoot(ElementName = "Component")]
    public class Component
    {
        [XmlAttribute(AttributeName = "Name")]
        public string Name { get; set; }

        [XmlAttribute(AttributeName = "DisplayName")]
        public string DisplayName { get; set; }

        [XmlAttribute(AttributeName = "DomainType")]
        public string DomainType { get; set; }

        [XmlAttribute(AttributeName = "GenerateType")]
        public string GenerateType { get; set; }

        [XmlAttribute(AttributeName = "PersistType")]
        public string PersistType { get; set; }

        [XmlIgnore]
        public GroupType GroupName { get; set; }
    }

    [XmlRoot(ElementName = "Group")]
    public class Group
    {
        public Group() { }
        public Group(List<Component> Component, GroupType Name)
        {
            this.Component = Component;
            this.Name = Name;
        }

        [XmlElement(ElementName = "Component")]
        public List<Component> Component { get; set; }

        [XmlAttribute(AttributeName = "Name")]
        public GroupType Name { get; set; }
    }

    [XmlRoot(ElementName = "ComponentConfig")]
    public class Components
    {
        [XmlElement(ElementName = "Group")]
        public List<Group> Group { get; set; }
    }
}
