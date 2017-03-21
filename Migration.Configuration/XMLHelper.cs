using Migration.Common;
using Migration.Configuration.ConfigObject;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Linq;
using System.Xml.Schema;
using System.Xml.Serialization;

namespace Migration.Configuration
{
    public static class XMLHelper
    {
        public static Transformations Transforms { get; set; }
        public static Components Components { get; set; }
        public static PreRequisites PreRequisites { get; set; }
        static XMLHelper()
        {
            try
            {
                XmlSerializer serializerTransformations = new XmlSerializer(typeof(Transformations));
                XmlSerializer serializerComponents = new XmlSerializer(typeof(Components));
                XmlSerializer serializerPreRequisite = new XmlSerializer(typeof(PreRequisites));

                string transformFilePath = "ConfigXML/TransformationConfiguration.xml";
                string componentFilePath = "ConfigXML/ComponentConfiguration.xml";
                string preReqFilePath = "ConfigXML/PreRequisiteConfiguration";

                using (StreamReader readerPreRequisites = new StreamReader(preReqFilePath))
                {
                    PreRequisites = (PreRequisites)serializerPreRequisite.Deserialize(readerPreRequisites);
                }

                if (File.Exists(transformFilePath) && File.Exists(componentFilePath)) // For Unit Test - Need to handle Properly 
                {
                    if (Validate(transformFilePath, Resources.TransformationXSD))
                    {
                        using (StreamReader readerTransformations = new StreamReader(transformFilePath))
                        {
                            Transforms = (Transformations)serializerTransformations.Deserialize(readerTransformations);
                        }
                    }
                    else
                        throw new Exception("Transformation XML Validation Failed");

                    if (Validate(componentFilePath, Resources.ComponentXSD))
                    {
                        using (StreamReader readerComponents = new StreamReader(componentFilePath))
                        {
                            Components = (Components)serializerComponents.Deserialize(readerComponents);
                        }
                    }
                    else
                        throw new Exception("Component XML Validation Failed");
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
        private static bool Validate(string xmlFilePath,string xsdFile)
        {
            try
            {
                bool isValid = true;

                XmlSchemaSet schemas = new XmlSchemaSet();
                schemas.Add("", XmlReader.Create(new StringReader(xsdFile),new XmlReaderSettings()));

                XDocument custOrdDoc = XDocument.Load(xmlFilePath);

                custOrdDoc.Validate(schemas, (o, e) =>
                {
                    Logger.Instance.LogError("XML Validation Failed :", new Exception(e.Message));
                    isValid = false;
                });

                return isValid;
            }
            catch (Exception)
            {
                throw ;
            }
        }
    }
}
