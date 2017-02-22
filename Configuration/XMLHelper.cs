using Migration.Configuration.ConfigObject;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace Migration.Configuration
{
    public static class XMLHelper
    {
        public static Transformations Transforms { get; set; }
        public static Components Components { get; set; }
        static XMLHelper()
        {
            XmlSerializer serializerTransformations = new XmlSerializer(typeof(Transformations));
            XmlSerializer serializerComponents = new XmlSerializer(typeof(Components));

            if (File.Exists("ConfigXML/TransformationConfiguration.xml") && File.Exists("ConfigXML/ComponentConfiguration.xml"))
            {
                StreamReader readerTransformations = new StreamReader("ConfigXML/TransformationConfiguration.xml");
                StreamReader readerComponents = new StreamReader("ConfigXML/ComponentConfiguration.xml");

                Transforms = (Transformations)serializerTransformations.Deserialize(readerTransformations);
                Components = (Components)serializerComponents.Deserialize(readerComponents);

                readerTransformations.Close();
                readerComponents.Close();
            }
        }
    }
}
