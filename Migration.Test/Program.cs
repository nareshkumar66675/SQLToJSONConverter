using Dapper;
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
using static Slapper.AutoMapper.Configuration;

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
    public class DictionaryConverter : ITypeConverter
    {
        public int Order => 110;

        public bool CanConvert(object value, Type type)
        {
            // Handle Nullable types
            var conversionType = Nullable.GetUnderlyingType(type) ?? type;
            //Check if Type is a Dictionary
            return conversionType.IsGenericType && conversionType.GetGenericTypeDefinition() == typeof(Dictionary<,>);
        }

        public object Convert(object value, Type type)
        {
            // Handle Nullable types
            var conversionType = Nullable.GetUnderlyingType(type) ?? type;
            //Create Empty Instance
            object result = Activator.CreateInstance(type);
            if (value != null)
            {
                try
                {
                    result = JsonConvert.DeserializeObject(value as string, type);
                }
                catch (JsonException ex)
                {
                    throw new Exception("Invalid JSON String while Converting to Dictionary Object", ex);
                }
            }
            return result;
        }
    }
    class Program
    {
        static void Main(string[] args)
        {
            const string sql = @"Declare @id int =1
            IF OBJECT_ID('tempdb..#temp') IS NOT NULL  
            DROP TABLE #temp;  
            CREATE table #temp(Id int,[Data] varchar(max),[value] varchar(50))
            WHILE @id<6 
            BEGIN  
            DEclare @count int =1
            DECLARE @text varchar(max);
            while @count<2
            BEGIN

            Set @text = '
                    ""ASSET.MASTER.NETWORK.TYPE"": ""Ethernet"",
                    ""ASSET.MASTER.ASSET.TYPE"": ""EGM"",
                    ""ASSET.MASTER.CONFIGURATION.STATUS"": ""Online"",
                    ""ASSET.MULTI.DENOM"": """",
                    ""ASSET.VAR.HOLD.PERCENT"": ""Yes"",
                    ""ASSET.MULTI.GAME"": """",
                    ""ASSET.VALID.FILL.NUMBER"": """",
                    ""ASSET.STOOL"": """",
                    ""ASSET.VAL.MFG"": """",
                    ""ASSET.TOURNAMENT.PLAY"": """",
                    ""ASSET.VIDEO.GAME"": """",
                    ""ASSET.CREDIT.GAME"": """",
                    ""ASSET.GAME.TYPE"": ""A"",
                    ""ASSET.TOKENIZED"": """",
                    ""ASSET.ECASH.ENABLED"": ""No"",
                    ""ASSET.TICKET.PRINTER"": ""No"",
                    ""ASSET.COIN.ACC"": ""No"",
                    ""ASSET.COIN.HOP"": ""No"",
                    ""ASSET.E.PRINTER"": ""No"",
                    ""ASSET.PLAYABLE.TKT"": ""No"",
                    ""ASSET.CASH.CLUB.ENAB"": ""Normal"",
                    ""ASSET.GAME.CAPPING"": ""No"",
                    ""ASSET.ROULETTE"": ""No"",
                    ""ASSET.SMART.CARD"": ""No"",
                    ""MAG.STRIP.CARD"": ""No"",
                    ""ASSET.GAME.SUPPORTS.AUTO.PAY"": ""No"",
                    ""ASSET.ROM.SIG.ENABLED"": ""No"",
                    ""ASSET.GMU.CRC.AUTH"": ""N"",
                    ""ASSET.CASLESS.DISAB"": ""N"",
                    ""ASSET.MULTI.CURRENCY.SUPPORT"": ""No"",
                    ""ASSET.VOUCHER.VALIDATION.TYPE"": """",
                    ""OPTION.CODE.METER.TYPE"": """",
                    ""ASSET.NUMBER"": ""23454"",
                    ""ASSET.LOCATION"": ""233243"",
                    ""ASSET.LINE.ADDRESS"": """",
                    ""ASSET.SERIAL.NUMBER"": ""sd5454"",
                    ""ASSET.ASL.POSITION"": """",
                    ""ASSET.MASTER.DISPOSITION"": """",
                    ""ASSET.MASTER.LOCATION.X"": """",
                    ""ASSET.MASTER.LOCATION.Y"": """",
                    ""ASSET.MASTER.LOCATION.Z"": """",
                    ""ASSET.MASTER.LOCATION.R"": """",
                    ""ASSET.MASTER.PURCHASED.AMOUNT"": """",
                    ""ASSET.MASTER.SOLD.AMOUNT"": """",
                    ""ASSET.MASTER.EGM.ID"": """",
                    ""ASSET.CAROUSEL"": """",
                    ""ASSET.CAMERA.1"": """",
                    ""ASSET.CAMERA.2"": """",
                    ""ASSET.NJ.SEAL"": ""4545343"",
                    ""ASSET.REEL.STRIP"": """",
                    ""ASSET.PAGER.ZONE"": """",
                    ""ASSET.DESCRIPTION.NUMBER"": """",
                    ""ASSET.GAME.EPROM.ID"": """",
                    ""ASSET.MACHINE.SIZE"": """",
                    ""ASSET.BILL.SER.NO"": """",
                    ""ASSET.LIFE.CYCLE"": """",
                    ""ASSET.AUX.FILL.DOOR.NO"": """",
                    ""ASSET.MAXIMUM.COIN.IN"": """",
                    ""ASSET.MAX.HANDLE.PULL.PER.MIN"": """",
                    ""ASSET.GMU.DOC.ID"": """",
                    ""ASSET.GAME.PROTOCOL"": """",
                    ""ASSET.GAME.PROG.ID"": """",
                    ""ASSET.USER.CUSTOM.2"": """",
                    ""ASSET.USER.CUSTOM.5"": """",
                    ""ASSET.USER.CUSTOM.6"": """",
                    ""ASSET.USER.CUSTOM.7"": """",
                    ""ASSET.USER.CUSTOM.8"": """",
                    ""ASSET.USER.CUSTOM.9"": """",
                    ""ASSET.USER.CUSTOM.10"": """",
                    ""ASSET.ROULETTE.ID"": """",
                    ""ASSET.STANDARD.ERROR"": """",
                    ""ASSET.PROG.RATE"": """",
                    ""ASSET.EPROM.ID"": """",
                    ""ASSET.PROGRESSIVE"": """",
                    ""ASSET.CRC.REQ.DATE"": """",
                    ""ASSET.CRC.REQ.TIME"": """",
                    ""ASSET.CRC.COUNT"": """",
                    ""ASSET.CRC.ERROR"": """",
                    ""PROTOCOL.VERSION"": """",
                    ""BILL.VALIDATOR.CAPACITY"": ""342"",
                    ""ASSET.ROM.SIG.STATUS"": """",
                    ""ASSET.VALUE"": """",
                    ""ASSET.LIFE.SPAN"": """",
                    ""OPTION.CODE.PURCHASED.DATE"": """",
                    ""OPTION.CODE.ENROLMENT.STATUS"": """"
                }';

            insert into #temp values(@id,@text,@count)
            insert into #temp values(@id,NULL,Null)
            set @count=@count+1;
            END
            set @id=@id+1;
            END 
            select * from #temp order by id";

            string connectionString = @"Data Source=10.2.143.100;Integrated Security=False;User ID=sa;Password=abc@123;Initial Catalog=ALH_AssetMatrix14";

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                {


                    dynamic test = conn.Query<dynamic>(sql);
                    //var li = conn.Query<dynamic>(sql).ToList();

                    //Slapper.AutoMapper.Configuration.AddIdentifiers(typeof(BallyTech.Library.Domain.Employee.Task), new List<string> { "Id" });
                    //Slapper.AutoMapper.Configuration.AddIdentifiers(typeof(Module), new List<string> { "Id" });
                    //Type ft = Type.GetType("Migration.Test.Module,Migration.Test");
                    //Activator.CreateInstance("Migration.Test", "Migration.Test.Module");
                    //var obj=Activator.CreateInstance(ft);
                    //var testContact = (Slapper.AutoMapper.MapDynamic(ft, test) as IEnumerable<Object>).ToList();
                    //string s = JsonConvert.SerializeObject(testContact);
                    //ProcessQueue.ProcessQueue.Processes.Enqueue(new ProcessItem(new Migration.Configuration.ConfigObject.Component(), testContact));
                    //ProcessQueue.ProcessQueue.Processes.Take()
                    //IEnumerable t = test;
                    //List<object> not = new List<object>();
                    //for (int i = 0; i < 192; i++)
                    //{
                    //    if(testContact.Exists(vt=>vt.Id == test[i].Id ))

                    //    {
                    //        not.Add(test[i].Id);
                    //    }
                    //}
                    //StringBuilder sb = new StringBuilder();
                    //foreach (var c in testContact)
                    //{
                    //    sb.AppendLine(c.Id.ToString());
                    //}
                    //File.AppendAllText(@"C:\Users\105171\Desktop\New Text Document.txt", sb.ToString());

                    TypeConverters.Add(new DictionaryConverter());
                    var rslt = Slapper.AutoMapper.MapDynamic<TestEntity>(test);

                    Console.ReadLine();
                }
            }

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
