using Migration.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace Migration.Configuration.ConfigObject
{
    /// <summary>
    /// Column Map Details
    /// </summary>
    [XmlRoot(ElementName = "ColumnMap")]
    public class ColumnMap
    {
        public ColumnMap() { }
        public ColumnMap(string key,string columnName)
        {
            this.Key = key;
            this.ColumnName = columnName;
        }
        /// <summary>
        /// Key used in Source Query
        /// </summary>
        [XmlAttribute(AttributeName = "Key")]
        public string Key { get; set; }
        /// <summary>
        /// Column/MemberName used in Entity
        /// </summary>
        [XmlAttribute(AttributeName = "ColumnName")]
        public string ColumnName { get; set; }
    }
    /// <summary>
    /// ColumnMapping Needed - If SQL Column Name exceeds 128 characters, SQL Server Restriction
    /// </summary>
    [XmlRoot(ElementName = "ColumnMapping")]
    public class ColumnMapping
    {
        [XmlElement(ElementName = "ColumnMap")]
        public List<ColumnMap> ColumnMap { get; set; }
    }
    /// <summary>
    /// Data Format for Sql Table Primary Column - [Key]
    /// </summary>
    [XmlRoot(ElementName = "KeyFormat")]
    public class KeyFormat
    {
        /// <summary>
        /// Parametrised String Ex: hello_{0}!
        /// </summary>
        [XmlAttribute(AttributeName = "Format")]
        public string Format { get; set; }
        /// <summary>
        /// Result Column Names - Seperated by Comma (,) Ex: Id,Sample.Id
        /// </summary>
        [XmlAttribute(AttributeName = "Keys")]
        public string Keys { get; set; }
    }
    [XmlRoot(ElementName = "Transformation")]
    public class Transformation
    {
        /// <summary>
        /// Unique Name - Refers from Component Config
        /// </summary>
        [XmlAttribute(AttributeName = "Name")]
        public string Name { get; set; }
        /// <summary>
        /// Source Query String
        /// 
        /// Ignoring to Reduce Physical Memory Usage - Reads From XML File
        /// </summary>
        [XmlIgnore]
        public string Source { get; set; }
        /// <summary>
        /// Destination Table Name
        /// </summary>
        [XmlElement(ElementName = "Destination")]
        public string Destination { get; set; }
        /// <summary>
        /// Data Format for Sql Table Primary Column - [Key]
        /// </summary>
        [XmlElement(ElementName = "KeyFormat")]
        public KeyFormat KeyFormat { get; set; }
        /// <summary>
        /// ColumnMapping Needed - If SQL Column Name exceeds 128 characters, SQL Server Restriction
        /// </summary>
        [XmlElement(ElementName = "ColumnMapping")]
        public ColumnMapping ColumnMapping { get; set; }
        /// <summary>
        /// Custom Unique Columns - To Group Data
        /// Default Unique Columns are - Id, xxxId
        /// </summary>
        [XmlElement(ElementName = "UniqueMembers")]
        public UniqueMembers UniqueMembers { get; set; }
        /// <summary>
        /// Dynamic Parameters for Source Query
        /// </summary>
        [XmlIgnore]
        public List<string> QueryParams { get; set; }
    }
    /// <summary>
    /// List Of Custom Unique Columns
    /// </summary>
    [XmlRoot(ElementName = "UniqueColumn")]
    public class UniqueColumn
    {
        [XmlElement(ElementName = "Column")]
        public List<string> Column { get; set; }
        [XmlAttribute(AttributeName = "type")]
        public string Type { get; set; }
    }

    [XmlRoot(ElementName = "UniqueMembers")]
    public class UniqueMembers
    {
        [XmlElement(ElementName = "UniqueColumn")]
        public List<UniqueColumn> UniqueColumn { get; set; }
    }
    /// <summary>
    /// Root Element
    /// </summary>
    [XmlRoot(ElementName = "TransformationConfig")]
    public class Transformations
    {
        /// <summary>
        /// List of Transformations
        /// </summary>
        [XmlElement(ElementName = "Transformation")]
        public List<Transformation> Transformation { get; set; }
    }
}
