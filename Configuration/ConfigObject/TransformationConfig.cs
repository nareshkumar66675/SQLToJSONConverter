using Migration.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace Migration.Configuration.ConfigObject
{
    [XmlRoot(ElementName = "Transformation")]
    public class Transformation
    {
        [XmlAttribute(AttributeName = "Name")]
        public string Name { get; set; }
        [XmlElement(ElementName = "Source")]
        public string Source { get; set; }
        [XmlElement(ElementName = "Destination")]
        public string Destination { get; set; }
        [XmlElement(ElementName = "KeyFormat")]
        public KeyFormat KeyFormat { get; set; }
        [XmlIgnore]
        public List<string> QueryParams { get; set; }
    }
    [XmlRoot(ElementName = "KeyFormat")]
    public class KeyFormat
    {
        [XmlAttribute(AttributeName = "Format")]
        public string Format { get; set; }
        [XmlAttribute(AttributeName = "Keys")]
        public string Keys { get; set; }
        //[XmlAttribute(AttributeName = "KeyType")]
        //public KeyType KeyType { get; set; }
    }
    [XmlRoot(ElementName = "TransformationConfig")]
    public class Transformations
    {
        [XmlElement(ElementName = "Transformation")]
        public List<Transformation> Transformation { get; set; }
    }
}
