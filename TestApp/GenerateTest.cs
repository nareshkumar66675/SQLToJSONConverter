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
        public Components components;
        [SetUp]
        public void GenerateInitailze()
        {
            XMLHelper.Components = new Components();
            Component comp = new Component();
            comp.Name = "GOT";
            comp.DomainType = "Migration.Test.GOT,Migration.Test";
            var compList = new List<Component>();
            compList.Add(comp);
            Group grp = new Group(compList, Common.GroupType.AUTH);
            var grpList = new List<Group>();
            grpList.Add(grp);
            XMLHelper.Components.Group = grpList;
            components = XMLHelper.Components;

            XMLHelper.Transforms = new Transformations();
            Transformation trnsfrm = new Transformation();
            trnsfrm.Name = "GOT";

            trnsfrm.Source = @"select GOT.Id,CharacterName,[Role],PlayedBy,Age,hs.Id as House_Id,HouseName as House_HouseName,HouseMotto as House_HouseMotto from GOT 
                                inner Join Houses hs on Got.Id = hs.Id";
            var trnsfrmList = new List<Transformation>();
            trnsfrmList.Add(trnsfrm);
            XMLHelper.Transforms.Transformation = trnsfrmList;
            SqlConnectionStringBuilder build = new SqlConnectionStringBuilder();
            //build.at
            string file = Path.Combine(Directory.GetCurrentDirectory() + @"\TestApp\TestDatabase.mdf");
            var t = File.Exists(file);
            var f = Directory.GetCurrentDirectory();
            Common.Common.ConnectionStrings.LegacyConnectionString = @"Data Source = (LocalDB)\MSSQLLocalDB; AttachDbFilename = """+file+@"""; Integrated Security = True;";
        }
        [Test]
        public void GenerateFactoryTest()
        {
            Assert.IsInstanceOf(typeof(GenericGenerator), GenerateFactory.GetGenerator("default"));
            Assert.IsInstanceOf(typeof(GenericGeneratorWtParams), GenerateFactory.GetGenerator("defaultwtparams"));
            Assert.IsInstanceOf(typeof(GenericGenerator), GenerateFactory.GetGenerator("XXX"));
        }
        [Test]
        public void GenericGenerateTest()
        {
            GenericGenerator gen = new GenericGenerator();
            Component comp = new Component();
            comp.Name = "GOT";
            comp.DomainType = "Migration.Test.GOT,Migration.Test"; 
            var result = gen.Generate(comp);
            Assert.IsTrue(result);
            ProcessItem data = null;
            ProcessQueue.ProcessQueue.Processes.CompleteAdding();
            ProcessQueue.ProcessQueue.Processes.TryTake(out data, 1000);
            ProcessQueue.ProcessQueue.Processes = new System.Collections.Concurrent.BlockingCollection<ProcessItem>();
            Assert.NotNull(data);
            Type type = Type.GetType("Migration.Test.GOT,Migration.Test");
            Assert.Greater(data.Items.Count, 0);
            Assert.IsInstanceOf(type, data.Items[0]);
        }
    }
}
