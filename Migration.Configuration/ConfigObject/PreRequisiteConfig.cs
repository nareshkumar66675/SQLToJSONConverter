using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace Migration.Configuration.ConfigObject
{
    /// <summary>
    /// PreRequisite Configuration
    /// </summary>
    [XmlRoot(ElementName = "PreRequisite")]
    public class PreRequisite
    {
        /// <summary>
        /// Unique PreRequisite Name
        /// </summary>
        [XmlAttribute(AttributeName = "Name")]
        public string Name { get; set; }
        /// <summary>
        /// Sql Script File Path
        /// </summary>
        [XmlAttribute(AttributeName = "ScriptFilePath")]
        public string ScriptFilePath { get; set; }
    }
    /// <summary>
    /// 
    /// </summary>
    [XmlRoot(ElementName = "PreRequisiteConfig")]
    public class PreRequisites
    {
        /// <summary>
        /// List of All PreRequisites Configurations
        /// </summary>
        [XmlElement(ElementName = "PreRequisite")]
        public List<PreRequisite> PreRequisite { get; set; }
    }
}
