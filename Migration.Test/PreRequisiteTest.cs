using Migration.Configuration;
using Migration.Configuration.ConfigObject;
using Migration.PreRequisite;
using Migration.PreRequisite.Facades;
using Migration.PreRequisite.PreRequisites;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Test
{
    [TestFixture(TestName = "PreRequiste Test", Author = "Naresh")]
    class PreRequisiteTest
    {
        string connString = string.Empty;
        [SetUp]
        public void PreRequisiteInitialize()
        {
            #region SetDirectory
            var binDir = Path.GetDirectoryName(typeof(PreRequisiteTest).Assembly.Location);
            Environment.CurrentDirectory = binDir;
            Directory.SetCurrentDirectory(binDir);
            #endregion

            #region PreRequsitesConfig

            connString = @"Data Source = (LocalDB)\MSSQLLocalDB; AttachDbFilename = """ + Path.Combine(binDir, "TestDatabase.mdf") + @"""; Integrated Security = True;";

            PreRequisites preReqs = new PreRequisites();
            preReqs.PreRequisite = new List<Migration.Configuration.ConfigObject.PreRequisite>();
            Migration.Configuration.ConfigObject.PreRequisite preReq = new Migration.Configuration.ConfigObject.PreRequisite();
            preReq.Name = "SansaPreReq";
            preReq.ScriptFilePath = Path.Combine(binDir,"TestScript.sql");
            preReqs.PreRequisite.Add(preReq);

            XMLHelper.PreRequisites = preReqs;
            #endregion
        }
        [Test(Description = "To Test PreRequiste Factory Method")]
        public void PreRequisiteFactoryTest()
        {
            Assert.IsInstanceOf(typeof(AssetFacade), PreRequisiteFactory.GetPreRequistes(Common.GroupType.ASSET));
            Assert.IsInstanceOf(typeof(AuthFacade), PreRequisiteFactory.GetPreRequistes(Common.GroupType.AUTH));
            Assert.IsInstanceOf(typeof(ReportFacade), PreRequisiteFactory.GetPreRequistes(Common.GroupType.REPORT));
        }
        [Test(Description = "To Test Facade Objects")]
        public void FacadeTest()
        {
            var facades = GetEnumerableOfType<AbstractPreRequisite>();

            //Validate if it has PreRequisites
            foreach (var facade in facades)
            {
                Assert.IsNotEmpty(facade.PreRequisites,$"PreRequistes is Empty for Facade { facade.GetType().Name}");
            }
        }
        [Test(Description = "To Test Execute Script PreRequisite")]
        public void ExecuteScriptPreRequisiteTest()
        {

            IPreRequisite preq = new ExecuteScriptPreRequisite("SansaPreReq", connString);
            preq.Execute();

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand("Select * from dbo.GOT Where CharacterName='Sansa Stark'", con))
                {
                    using (IDataReader dr = cmd.ExecuteReader())
                    {
                        DataTable table = new DataTable();
                        table.Load(dr);
                        //Assert.GreaterOrEqual(table.Rows.Count, 1,"PreRequsites Script Insertion Failed and retuned 0 records");
                        foreach (DataRow item in table.Rows)
                        {
                            Assert.AreEqual("Sansa Stark", item["CharacterName"].ToString());
                            Assert.AreEqual("Eldest Daughter of Stark", item["Role"].ToString());
                            Assert.AreEqual("Sophie Turner", item["PlayedBy"].ToString());
                            Assert.AreEqual("21", item["Age"].ToString());
                        }
                    }
                }
            }
        }

        private static IEnumerable<T> GetEnumerableOfType<T>() where T : class
        {
            List<T> objects = new List<T>();
            foreach (Type type in
                Assembly.GetAssembly(typeof(T)).GetTypes()
                .Where(myType => myType.IsClass && !myType.IsAbstract && myType.IsSubclassOf(typeof(T))))
            {
                objects.Add((T)Activator.CreateInstance(type));
            }
            return objects;
        }
        [TearDown]
        public void Clear()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand("delete from dbo.GOT Where CharacterName='Sansa Stark'", con))
                {
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }
}
