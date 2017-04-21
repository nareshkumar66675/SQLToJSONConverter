using Migration.Configuration;
using Migration.Configuration.ConfigObject;
using Migration.Generate;
using Migration.Generate.Generators;
using Migration.PreRequisite;
using Migration.PreRequisite.Facades;
using Migration.ProcessQueue;
using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Dynamic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Test
{
    public class TestEntity
    {
        public int Id { get; set; }
        public Dictionary<string,string> Data { get; set; }
    }
    public class TestEntity1
    {
        public TestEntityID Id { get; set; }
        public List<string> List { get; set; }
    }
    public class TestEntityID
    {
        [Slapper.AutoMapper.Id]
        public int Id { get; set; }
        public int TestId { get; set; }
    }
    class Program
    {
        static void Main(string[] args)
        {
            //   const string sql = @"SELECT DISTINCT
            //                           tp.MODL_ID as Id,
            //tc.FUNC_ID as Tasks_Id,
            //                           tc.FUNC_NAME Tasks_Name,
            //tc.FUNC_DESCRIPTION as [Tasks_Description]
            //                       FROM [COMMON].[USER_FUNCTION] tc
            //                            INNER JOIN [COMMON].[MODULE] tp ON tc.MODULE_ID = tp.MODL_ID where FUNC_ID>0";

            //   string connectionString = "Data Source=10.2.108.21\\MSSQLSERVER2K12;Integrated Security=False;User ID=sa;Password=abc@123;Initial Catalog=AssetMatrix_140_Demo";

            //   using (var conn = new SqlConnection(connectionString))
            //   {
            //       conn.Open();
            //       {


            //           dynamic test = conn.Query<dynamic>(sql);
            //           //var li = conn.Query<dynamic>(sql).ToList();

            //           //Slapper.AutoMapper.Configuration.AddIdentifiers(typeof(BallyTech.Library.Domain.Employee.Task), new List<string> { "Id" });
            //           //Slapper.AutoMapper.Configuration.AddIdentifiers(typeof(Module), new List<string> { "Id" });
            //           Type ft = Type.GetType("Migration.Test.Module,Migration.Test");
            //           //Activator.CreateInstance("Migration.Test", "Migration.Test.Module");
            //           //var obj=Activator.CreateInstance(ft);
            //           var testContact =  (Slapper.AutoMapper.MapDynamic(ft, test) as IEnumerable<Object>).ToList();
            //           string s =JsonConvert.SerializeObject(testContact);
            //           //ProcessQueue.ProcessQueue.Processes.Enqueue(new ProcessItem(new Migration.Configuration.ConfigObject.Component(), testContact));
            //           //ProcessQueue.ProcessQueue.Processes.Take()
            //           //IEnumerable t = test;
            //           //List<object> not = new List<object>();
            //           //for (int i = 0; i < 192; i++)
            //           //{
            //           //    if(testContact.Exists(vt=>vt.Id == test[i].Id ))

            //           //    {
            //           //        not.Add(test[i].Id);
            //           //    }
            //           //}
            //           //StringBuilder sb = new StringBuilder();
            //           //foreach (var c in testContact)
            //           //{
            //           //    sb.AppendLine(c.Id.ToString());
            //           //}
            //           //File.AppendAllText(@"C:\Users\105171\Desktop\New Text Document.txt", sb.ToString());
            //           Console.ReadLine();
            //       }
            //   }

            //Migration.Generate.Generate gen = new Migration.Generate.Generate();
            ////await gen.Start(Configuration.Configurator.Components, null);
            //Task a = gen.Start(Migration.Configuration.Configurator.SourceComponents, null);
            ////Task.Run(()=>gen.Start(Configuration.Configurator.Components, null));
            //a.Wait();
            //Persistence.Persist per = new Persistence.Persist();
            //Task b =  per.Start(null);
            //b.Wait();

            //AuthFacade fc = new AuthFacade();
            //fc.Start(null);

            //IDictionary<string, object> temp = new Dictionary<string, object>();
            //temp.Add("Id", "1");

            //IDictionary<string, string> temp1 = new Dictionary<string, string>();
            ////temp1.Add("1", "2");
            ////temp1.Add("2", "2");
            ////temp1.Add("3", "2");
            //temp.Add("Data_$", new Dictionary<string, string>() { { "Key1", "Value1" }, { "Key2", "Value2" } });
            ////temp.Add("Data_$", new List<string>() { "1", "2" });
            ////temp.Add("$.Data_Value", "dfvc");




            //IDictionary<string, object> entity = new Dictionary<string, object>();
            //entity.Add("Id", "1");
            //entity.Add("Data_Key", new List<string>() { "Key1", "Key2" });
            //entity.Add("Data_Value", new List<string>() { "Value1", "Value2" });
            //var result = Slapper.AutoMapper.Map<TestEntity>(entity);


            //Migration.Generate.Generate gen = new Migration.Generate.Generate();
            //gen.Start()

            //IGenerator gen = new GenericGeneratorWtParams();
            //Migration.Configuration.ConfigObject.Component temp = new Migration.Configuration.ConfigObject.Component();

            //temp.Name = "dsfgdf";
            //temp.DomainType = "BallyTech.Library.Persistence.MSSql.Entity.AssetHistory.AssetHistoryEntity,BallyTech.Library.Persistence.MSSql.Asset";
            //temp.GenerateType = "DefaultWithParams";
            //temp.PersistType = "Default";
            ////Transform 1
            //Transformation trnsfrm = new Transformation();
            //trnsfrm.Name = "dsfgdf";

            //trnsfrm.Source = @"select GOT.Id,CharacterName,[Role],PlayedBy,Age,hs.Id as House_Id,HouseName as House_HouseName,HouseMotto as House_HouseMotto from GOT 
            //                    inner Join Houses hs on Got.HouseId = hs.Id";
            //trnsfrm.Destination = "dbo.GOTv2";
            //trnsfrm.KeyFormat = new KeyFormat();
            //trnsfrm.KeyFormat.Format = "100_{0}";
            //trnsfrm.KeyFormat.Keys = "Id";

            //var trnsfrmList = new List<Transformation>();
            //trnsfrmList.Add(trnsfrm);
            //XMLHelper.Transforms.Transformation = trnsfrmList;

            //gen.Generate(temp);

            dynamic dynamicCustomer = new ExpandoObject();
            dynamicCustomer.Id_Id = 1;
            dynamicCustomer.Id_TestId = 10;

            dynamic dynamicCustomer2 = new ExpandoObject();
            dynamicCustomer2.Id_Id = 1;
            dynamicCustomer2.Id_TestId = 11;


            var list = new List<dynamic> { dynamicCustomer, dynamicCustomer2 };
            var customer = Slapper.AutoMapper.MapDynamic<TestEntity1>(list);

            //var result = Slapper.AutoMapper.Map<TestEntity1>(list);
        }
    }
}
