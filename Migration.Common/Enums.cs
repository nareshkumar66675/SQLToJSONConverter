using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace Migration.Common
{
    /// <summary>
    /// Groups
    /// </summary>
    [Serializable]
    public enum GroupType
    {
        /// <summary>
        /// Authorization Service
        /// </summary>
       [Description("Authorization Service")]
       [XmlEnum("AUTH")]
       AUTH,
       /// <summary>
       /// Asset Service
       /// </summary>
       [Description("Asset Service")]
       [XmlEnum("ASSET")]
        ASSET,
        /// <summary>
        /// Asset History Database
        /// </summary>
        [Description("Report Database")]
       [XmlEnum("REPORT")]
        REPORT,
        /// <summary>
        /// Asset History Database - same DB as <see cref="REPORT"/>
        /// </summary>
        [Description("History Database")]
        [XmlEnum("HISTORY")]
        HISTORY
    }
    public class EnumDescription<T>
    {
        public EnumDescription(string description, T enumName)
        {
            this.Description = description;
            this.EnumName = enumName;
        }
        public string Description { get; set; }
        public T EnumName { get; set; }
    }
    /// <summary>
    /// Custom Enum Extensions
    /// </summary>
    public static class EnumExtensions
    {
        /// <summary>
        /// Get Enum Description
        /// </summary>
        /// <param name="enumerationValue">Enum Value</param>
        /// <returns>Description</returns>
        public static string GetDescription(this Enum enumerationValue) 
        {
            var type = enumerationValue.GetType();
            if (!type.IsEnum)
            {
                throw new ArgumentException($"{nameof(enumerationValue)} must be of Enum type", nameof(enumerationValue));
            }
            var memberInfo = type.GetMember(enumerationValue.ToString());
            if (memberInfo.Length > 0)
            {
                var attrs = memberInfo[0].GetCustomAttributes(typeof(DescriptionAttribute), false);
                if (attrs.Length > 0)
                {
                    return ((DescriptionAttribute)attrs[0]).Description;
                }
            }
            return enumerationValue.ToString();
        }
    }
}
