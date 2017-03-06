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
using Migration.Common;

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
            catch (Exception ex)
            {
                if (AppSettings.IsReportEnabled)
                    SqlOperation.UpdatePersistReport(item.Component.Name, DateTime.Now, item.Items.Count, item.Component.GroupName,"Failed");
                Logger.Instance.LogError(string.Format("Error Occurred While Inserting Item : {0}" , item.Component.Name), ex);
                return false;
            }
        }

        private DataTable ConvertToCommonDataTable(List<object> items,KeyFormat keyFormat)
        {
            try
            {
                DataTable dataResult = new DataTable();
                dataResult.Columns.Add(new DataColumn("Key", typeof(string)));
                dataResult.Columns.Add(new DataColumn("Value", typeof(string)));

                items.ForEach((item) =>
                {
                    List<string> arr = new List<string>();
                    keyFormat.Keys.Split(',').ToList().ForEach(col => { arr.Add(GetPropertyValue(item,col) + string.Empty); });
                    dataResult.Rows.Add(string.Format(keyFormat.Format, arr.ToArray()), JSONConverter.SerializeObject(item));
                });
                return dataResult;
            }
            catch (Exception)
            {
                throw;
            }
        }
        private object GetPropertyValue(object src,string propName)
        {
            if (propName.Contains("."))
            {
                var temp = propName.Split(new char[] { '.' }, 2);
                return GetPropertyValue(GetPropertyValue(src, temp[0]), temp[1]);
            }
            else
            {
                var prop = src.GetType().GetProperty(propName);
                return prop != null ? prop.GetValue(src, null) : null;
            }
        }
    }
}
