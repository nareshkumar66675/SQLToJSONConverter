using Migration.Common;
using Migration.Configuration.ConfigObject;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using System.Xml.Serialization;

namespace Migration.Configuration
{
    public static class XMLHelper
    {
        public static Transformations Transforms { get; set; }
        public static Components Components { get; set; }
        static XMLHelper()
        {
            try
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
            catch (Exception ex)
            {
                Logger.Instance.LogError("Error Occurred While Intializing XML Configurations", ex);
                throw;
            }
        }
        /// <summary>
        /// Retrieves Transformation Source From XML - To Lazy Load SQL Query
        /// </summary>
        /// <param name="componentName">Name of the Component</param>
        /// <returns>Source Query</returns>
        internal static string GetTransformationSource(string componentName)
        {
            try
            {
                XElement ele = XElement.Load("ConfigXML/TransformationConfiguration.xml");

                string rslt = ele.Elements().Where(t => t.Attribute("Name").Value == componentName).FirstOrDefault().Descendants("Source").FirstOrDefault().Value;

                return rslt;
            }
            catch (Exception ex)
            {
                throw new Exception("Component Name or Source Not found in Transformation Xml", ex);
            }
        }
    }
}
