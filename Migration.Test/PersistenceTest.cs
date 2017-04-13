using Migration.Configuration;
using Migration.Configuration.ConfigObject;
using Migration.Generate.Generators;
using Migration.Persistence;
using Migration.Persistence.Persistences.Search;
using Migration.Persistence.Persistences.SQL;
using Migration.ProcessQueue;
using Newtonsoft.Json;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Test
{
    [TestFixture(TestName ="Persistence Test",Author ="Naresh")]
    public class PersistenceTest
    {
        [SetUp]
        public void GenerateInitailze()
        {
            var dir = Path.GetDirectoryName(typeof(PersistenceTest).Assembly.Location);
            Environment.CurrentDirectory = dir;

            Directory.SetCurrentDirectory(dir);

            #region ComponentsDeclaration
            XMLHelper.Components = new Components();

            //Component 1
            Component comp = new Component();
            comp.Name = "GOT";
            comp.DomainType = "Migration.Test.GOT,Migration.Test";

            var compList = new List<Component>();
            compList.Add(comp);

            Group grp = new Group(compList, Common.GroupType.AUTH);
            var grpList = new List<Group>();
            grpList.Add(grp);

            XMLHelper.Components.Group = grpList;

            #endregion

            #region TransformationsDeclaration
            XMLHelper.Transforms = new Transformations();

            //Transform 1
            Transformation trnsfrm = new Transformation();
            trnsfrm.Name = "GOT";

            trnsfrm.Source = @"select GOT.Id,CharacterName,[Role],PlayedBy,Age,hs.Id as House_Id,HouseName as House_HouseName,HouseMotto as House_HouseMotto from GOT 
                                inner Join Houses hs on Got.HouseId = hs.Id";
            trnsfrm.Destination = "dbo.GOTv2";
            trnsfrm.KeyFormat = new KeyFormat();
            trnsfrm.KeyFormat.Format = "100_{0}";
            trnsfrm.KeyFormat.Keys = "Id";

            var trnsfrmList = new List<Transformation>();
            trnsfrmList.Add(trnsfrm);
            XMLHelper.Transforms.Transformation = trnsfrmList;
            #endregion

            #region DatabaseDeclaration
            //DB Configurations
            string file = Path.Combine(Directory.GetCurrentDirectory() , "TestDatabase.mdf");

            Common.Common.ConnectionStrings.LegacyConnectionString = @"Data Source = (LocalDB)\MSSQLLocalDB; AttachDbFilename = """ + file + @"""; Integrated Security = True;";
            Common.Common.ConnectionStrings.AuthConnectionString = @"Data Source = (LocalDB)\MSSQLLocalDB; AttachDbFilename = """ + file + @"""; Integrated Security = True;";
            #endregion

            #region GenerateData
            //Process Data
            GenericGenerator gen = new GenericGenerator();
            var result = gen.Generate(comp); 
            #endregion

        }
        [Test]
        public void PersistenceFactoryTest()
        {
            Component comp = new Component();
            comp.PersistType = "default";
            comp.GroupName = Common.GroupType.AUTH;
            Assert.IsInstanceOf(typeof(SqlGenericPersistence), PersistenceFactory.GetPersistenceType(comp));
            comp.GroupName = Common.GroupType.ASSET;
            Assert.IsInstanceOf(typeof(SqlGenericPersistence), PersistenceFactory.GetPersistenceType(comp));
            comp.GroupName = Common.GroupType.REPORT;
            Assert.IsInstanceOf(typeof(SqlGenericPersistence), PersistenceFactory.GetPersistenceType(comp));
        }
        [Test]
        public void GenericSQLPersistenceTest()
        {
            SqlGenericPersistence per = new SqlGenericPersistence();
            ProcessItem data = null;
            ProcessQueue.ProcessQueue.Processes.TryTake(out data, 1000);
            
            Assert.IsNotNull(data);
            int srcCount = data.Items.Count;
            int destCount=0;
            per.Insert(data);
            
            using (SqlConnection con = new SqlConnection(Common.Common.ConnectionStrings.AuthConnectionString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand("Select * from dbo.GOTv2", con))
                {
                    using (IDataReader dr = cmd.ExecuteReader())
                    {
                        int i=0;
                        while (dr.Read())
                        {
                            var src = (GOT) data.Items[i];
                            var rowJSON=dr.GetString(1);
                            var temp=JsonConvert.DeserializeObject<GOT>(rowJSON);
                            Assert.IsInstanceOf<GOT>(temp);
                            var result = (GOT)temp;

                            Assert.AreEqual(src.Id, result.Id);
                            Assert.AreEqual(src.CharacterName, result.CharacterName);
                            Assert.AreEqual(src.PlayedBy, result.PlayedBy);
                            Assert.AreEqual(src.Role, result.Role);
                            Assert.AreEqual(src.Age, result.Age);
                            Assert.AreEqual(src.House.Id, result.House.Id);
                            Assert.AreEqual(src.House.HouseName, result.House.HouseName);
                            Assert.AreEqual(src.House.HouseMotto, result.House.HouseMotto);

                            destCount++;
                            i++;
                        }
                    }
                }
            }
            Assert.AreEqual(srcCount, destCount);
        }
        [TearDown]
        public void Clear()
        {
            using (SqlConnection con = new SqlConnection(Common.Common.ConnectionStrings.AuthConnectionString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(@"IF EXISTS(SELECT * FROM  dbo.GOTv2) Truncate Table dbo.GOTv2", con))
                {
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }
}
