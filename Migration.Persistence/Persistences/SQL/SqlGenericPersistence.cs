using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Migration.Configuration.ConfigObject;
using System.IO;
using Migration.Persistence.Helpers;
using Migration.ProcessQueue;
using System.Data;
using System.Diagnostics;
using Migration.Configuration;

namespace Migration.Persistence.Persistences.SQL
{
    public class SqlGenericPersistence : IPersistence
    {
        public bool Insert(ProcessItem item)
        {
            //Stopwatch st = new Stopwatch();
            SqlOperation.ExecuteBulkCopy(ConvertToCommonDataTable(item.Items,Configurator.GetKeyFormat(item.Component.Name)), item.Component.GroupName, Configurator.GetDestinationByComponentName(item.Component.Name));
            //st.Stop();
            //Trace.Write(st.Elapsed.ToString());
            return true;
        }

        private DataTable ConvertToCommonDataTable(List<object> items,KeyFormat keyFormat)
        {
            DataTable dataResult = new DataTable();
            dataResult.Columns.Add(new DataColumn("Key", typeof(string)));
            dataResult.Columns.Add(new DataColumn("Value", typeof(string)));

            items.ForEach((item) => {
                List<string> arr = new List<string>();
                keyFormat.Keys.Split(',').ToList().ForEach(col => { arr.Add(item.GetType().GetProperty(col).GetValue(item)+""); });
                dataResult.Rows.Add(string.Format(keyFormat.Format, arr.ToArray()), JSONConverter.SerializeObject(item));
            });
            return dataResult;
        }
    }
}
