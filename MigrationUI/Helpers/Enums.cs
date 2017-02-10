using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MigrationTool.Helpers
{
    public enum AuthenticationType
    {
        [Description("SQL Server Authentication")]
        SQLServer,
        [Description("Windows Authentication")]
        Windows
    }
    public static class Extensions
    {
        //public static string GetDescription(this Enum value)
        //{
        //    var fieldInfo = value.GetType().GetField(value.GetName());
        //    var descriptionAttribute = fieldInfo.GetCustomAttributes(typeof(DescriptionAttribute), false).FirstOrDefault() as DescriptionAttribute;
        //    return descriptionAttribute == null ? value.GetName() : descriptionAttribute.Description;
        //}
    }
}
