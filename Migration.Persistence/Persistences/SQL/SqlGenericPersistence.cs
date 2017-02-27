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
using static Migration.Common.Common;

namespace Migration.Persistence.Persistences.SQL
{
    public class SqlGenericPersistence : IPersistence
    {
        public bool Insert(ProcessItem item)
        {
            try
            {
                SqlOperation.ExecuteBulkCopy(ConvertToCommonDataTable(item.Items, Configurator.GetKeyFormat(item.Component.Name)), item.Component.GroupName, Configurator.GetDestinationByComponentName(item.Component.Name));

                if(AppSettings.IsReportEnabled)
                    SqlOperation.UpdatePersistReport(item.Component.Name, DateTime.Now, item.Items.Count, item.Component.GroupName,"Success");

                return true;
            }
            catch (Exception)
            {
                if (AppSettings.IsReportEnabled)
                    SqlOperation.UpdatePersistReport(item.Component.Name, DateTime.Now, item.Items.Count, item.Component.GroupName,"Failed");
                return false;
            }
        }

        private DataTable ConvertToCommonDataTable(List<object> items,KeyFormat keyFormat)
        {
            DataTable dataResult = new DataTable();
            dataResult.Columns.Add(new DataColumn("Key", typeof(string)));
            dataResult.Columns.Add(new DataColumn("Value", typeof(string)));

            items.ForEach((item) => {
                List<string> arr = new List<string>();
                keyFormat.Keys.Split(',').ToList().ForEach(col => { arr.Add(item.GetType().GetProperty(col).GetValue(item)+string.Empty); });
                dataResult.Rows.Add(string.Format(keyFormat.Format, arr.ToArray()), JSONConverter.SerializeObject(item));
            });
            return dataResult;
        }
    }
}
