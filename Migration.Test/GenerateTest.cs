using Migration.Configuration;
using Migration.Configuration.ConfigObject;
using Migration.Generate;
using Migration.Generate.Generators;
using Migration.ProcessQueue;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Test.Generate
{
    [TestFixture(TestName = "Generate Test", Author = "Naresh")]
    public class GenerateTest
    {
        [SetUp]
        public void GenerateInitailze()
        {

            #region SetDirectory
            var binDir = Path.GetDirectoryName(typeof(GenerateTest).Assembly.Location);
            Environment.CurrentDirectory = binDir;

            Directory.SetCurrentDirectory(binDir); 
            #endregion

            #region ComponentsDeclaration
            var compList = new List<Component>();
            //Component 1
            Component comp1 = new Component();
            comp1.Name = "GOT";
            comp1.DomainType = "Migration.Test.GOT,Migration.Test";
            comp1.GenerateType = "Default";

            //Component 2
            Component comp2 = new Component();
            comp2.Name = "GOTHOUSE";
            comp2.DomainType = "Migration.Test.GOT,Migration.Test";
            comp2.GenerateType = "DEFAULTWITHPARAMS";

            //Component 3
            Component comp3 = new Component();
            comp3.Name = "GOTMAP";
            comp3.DomainType = "Migration.Test.GOT,Migration.Test";
            comp3.GenerateType = "Default"; 
            

            compList.Add(comp1);
            compList.Add(comp2);
            compList.Add(comp3);

            Group grp = new Group(compList, Common.GroupType.AUTH);
            var grpList = new List<Group>();
            grpList.Add(grp);

            XMLHelper.Components = new Components();
            XMLHelper.Components.Group = grpList;

            #endregion

            #region TransformationDeclaration

            XMLHelper.Transforms = new Transformations();

            //Transform 1
            Transformation trnsfrm1 = new Transformation();
            trnsfrm1.Name = "GOT";

            trnsfrm1.Source = @"select GOT.Id,CharacterName,[Role],PlayedBy,Age,hs.Id as House_Id,HouseName as House_HouseName,HouseMotto as House_HouseMotto from GOT 
                                inner Join Houses hs on Got.HouseId = hs.Id";

            //Transform 2
            Transformation trnsfrm2 = new Transformation();
            trnsfrm2.Name = "GOTHOUSE";

            trnsfrm2.Source = @"select GOT.Id,CharacterName,[Role],PlayedBy,Age,hs.Id as House_Id,HouseName as House_HouseName,HouseMotto as House_HouseMotto from GOT 
                                inner Join Houses hs on Got.HouseId = hs.Id Where Got.HouseId = {0}";

            //Transform 3
            Transformation trnsfrm3 = new Transformation();
            trnsfrm3.Name = "GOTMAP";

            trnsfrm3.Source = @"select GOT.Id,CharacterName,[Role],PlayedBy,Age,hs.Id as HH_Id,HouseName as HH_HN,HouseMotto as HH_HM from GOT 
                                inner Join Houses hs on Got.HouseId = hs.Id";
            ColumnMapping map = new ColumnMapping();
            map.ColumnMap = new List<ColumnMap>();
            map.ColumnMap.Add(new ColumnMap("HH", "House"));
            map.ColumnMap.Add(new ColumnMap("HN", "HouseName"));
            map.ColumnMap.Add(new ColumnMap("HM", "HouseMotto"));
            trnsfrm3.ColumnMapping = map;

            var trnsfrmList = new List<Transformation>();

            trnsfrmList.Add(trnsfrm1);
            trnsfrmList.Add(trnsfrm2);
            trnsfrmList.Add(trnsfrm3);

            XMLHelper.Transforms.Transformation = trnsfrmList;

            #endregion

            #region DatabaseDeclaration
            string file = Path.Combine(Directory.GetCurrentDirectory() , "TestDatabase.mdf");

            Common.Common.ConnectionStrings.LegacyConnectionString = @"Data Source = (LocalDB)\MSSQLLocalDB; AttachDbFilename = """ + file + @"""; Integrated Security = True;"; 
            #endregion
        }
        [Test(Description = "To Test Generate Factory Method")]
        public void GenerateFactoryTest()
        {
            Assert.IsInstanceOf(typeof(GenericGenerator), GenerateFactory.GetGenerator("default"));
            Assert.IsInstanceOf(typeof(GenericGeneratorWtParams), GenerateFactory.GetGenerator("DEFAULTWITHPARAMS"));
            Assert.IsInstanceOf(typeof(AuthReportData), GenerateFactory.GetGenerator("AUTHDATA"));
            Assert.IsInstanceOf(typeof(AssetReportData), GenerateFactory.GetGenerator("ASSETDATA"));
            Assert.IsInstanceOf(typeof(GenericGenerator), GenerateFactory.GetGenerator("XXX"));
        }
        [Test(Description = "To Check Default Generate type - GenericGenerator")]
        public void GenericGenerateTest()
        {
            Type type = Type.GetType("Migration.Test.GOT,Migration.Test");
            ProcessItem data = null;
            GenericGenerator gen = new GenericGenerator();

            var component = XMLHelper.Components.Group.Where(t => t.Name == Common.GroupType.AUTH).FirstOrDefault().Component.Where(u => u.Name == "GOT").FirstOrDefault();
            Assert.IsNotNull(component);

            var result = gen.Generate(component);
            Assert.IsTrue(result);

            ProcessQueue.ProcessQueue.Processes.CompleteAdding();
            ProcessQueue.ProcessQueue.Processes.TryTake(out data, 1000);
            ProcessQueue.ProcessQueue.Processes = new System.Collections.Concurrent.BlockingCollection<ProcessItem>();
            Assert.NotNull(data);

            Assert.Greater(data.Items.Count, 0);
            Assert.IsInstanceOf<List<object>>(data.Items);
            Assert.IsInstanceOf(type, data.Items[0]);
        }
        [Test(Description ="To Check GenericGenerator With Query Params")]
        public void GenericGeneratorWtParamsTest()
        {
            //House Stark Only
            Configurator.SetQueryParams("GOTHOUSE", new List<string> { "4" });
            ProcessItem data = null;
            Type type = Type.GetType("Migration.Test.GOT,Migration.Test");

            GenericGeneratorWtParams gen = new GenericGeneratorWtParams();

            var component =XMLHelper.Components.Group.Where(t => t.Name == Common.GroupType.AUTH).FirstOrDefault().Component.Where(u => u.Name == "GOTHOUSE").FirstOrDefault();
            Assert.IsNotNull(component);

            var result = gen.Generate(component);
            Assert.IsTrue(result);

            ProcessQueue.ProcessQueue.Processes.CompleteAdding();
            ProcessQueue.ProcessQueue.Processes.TryTake(out data, 1000);
            ProcessQueue.ProcessQueue.Processes = new System.Collections.Concurrent.BlockingCollection<ProcessItem>();

            Assert.NotNull(data);
            Assert.Greater(data.Items.Count, 0);
            Assert.IsInstanceOf<List<object>>(data.Items);
            Assert.IsInstanceOf(type, data.Items[0]);

            var stark =data.Items.Cast<GOT>().ToList();
            Assert.AreEqual(stark.Where(t => t.House.Id != 4).Count(), 0);
        }
        [Test(Description ="Test to check If Column Mapping Works")]
        public void GenericGenerateWtMapppingTest()
        {
            Type type = Type.GetType("Migration.Test.GOT,Migration.Test");
            ProcessItem data = null;
            GenericGenerator gen = new GenericGenerator();

            var component = XMLHelper.Components.Group.Where(t => t.Name == Common.GroupType.AUTH).FirstOrDefault().Component.Where(u => u.Name == "GOTMAP").FirstOrDefault();
            Assert.IsNotNull(component);

            var result = gen.Generate(component);
            Assert.IsTrue(result);

            ProcessQueue.ProcessQueue.Processes.CompleteAdding();
            ProcessQueue.ProcessQueue.Processes.TryTake(out data, 1000);
            ProcessQueue.ProcessQueue.Processes = new System.Collections.Concurrent.BlockingCollection<ProcessItem>();
            Assert.NotNull(data);

            Assert.Greater(data.Items.Count, 0);
            Assert.IsInstanceOf<List<object>>(data.Items);
            Assert.IsInstanceOf(type, data.Items[0]);

            var stark = data.Items.Cast<GOT>().ToList();

            stark.ForEach(person =>
            {
                Assert.IsNotNull(person.House.Id);
                Assert.IsNotNull(person.House.HouseName);
                Assert.IsNotNull(person.House.HouseMotto);
            });

        }
    }
}
