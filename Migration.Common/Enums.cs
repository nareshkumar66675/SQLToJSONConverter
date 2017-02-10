using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace Migration.Common
{
    [Serializable]
    public enum GroupType
   {
       [Description("Auth Service")]
       [XmlEnum("AUTH")]
       AUTH,
       [Description("Asset Service")]
        [XmlEnum("ASSET")]
        ASSET,
       [Description("Search Service")]
        [XmlEnum("SEARCH")]
        SEARCH
   }
}
