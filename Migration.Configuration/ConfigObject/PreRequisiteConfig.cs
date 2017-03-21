using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace Migration.Configuration.ConfigObject
{
    [XmlRoot(ElementName = "PreRequisite")]
    public class PreRequisite
    {
        [XmlAttribute(AttributeName = "Name")]
        public string Name { get; set; }
        [XmlAttribute(AttributeName = "ScriptFilePath")]
        public string ScriptFilePath { get; set; }
        [XmlAttribute(AttributeName = "Skip")]
        public string Skip { get; set; }
    }

    [XmlRoot(ElementName = "PreRequisiteConfig")]
    public class PreRequisites
    {
        [XmlElement(ElementName = "PreRequisite")]
        public List<PreRequisite> PreRequisite { get; set; }
    }
}
