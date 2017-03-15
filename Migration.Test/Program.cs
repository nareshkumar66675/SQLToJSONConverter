using Dapper;
using Migration.ProcessQueue;
using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Test
{
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

            //Generate.Generate gen = new Generate.Generate();
            ////await gen.Start(Configuration.Configurator.Components, null);
            //Task a =Task.Factory.StartNew(() => gen.Start(Configuration.Configurator.SourceComponents, null));
            ////Task.Run(()=>gen.Start(Configuration.Configurator.Components, null));
            //a.Wait();
            //Persistence.Persist per = new Persistence.Persist();


        }
    }
}
