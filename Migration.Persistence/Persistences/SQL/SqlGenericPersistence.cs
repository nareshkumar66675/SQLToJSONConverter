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
    /// <summary>
    /// Generic SQL Persistence
    /// </summary>
    public class SqlGenericPersistence : IPersistence
    {
        /// <summary>
        /// Persists Data Item
        /// </summary>
        /// <param name="item">Data</param>
        /// <returns></returns>
        public virtual bool Insert(ProcessItem item)
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
                Logger.Instance.LogError($"Error Occurred While Inserting Item : {item.Component.Name}", ex);
                return false;
            }
        }
        /// <summary>
        /// Serializes Object and Converts to Datatbale
        /// Key - Value Format
        /// </summary>
        /// <param name="items">Data</param>
        /// <param name="keyFormat">Key Column Format</param>
        /// <returns>Datatable</returns>
        protected DataTable ConvertToCommonDataTable(List<object> items,KeyFormat keyFormat)
        {
            try
            {
                DataTable dataResult = new DataTable();
                dataResult.Columns.Add(new DataColumn("Key", typeof(string)));
                dataResult.Columns.Add(new DataColumn("Value", typeof(string)));

                items.ForEach((item) =>
                {
                    string key = string.Empty;
                    string value = string.Empty;
                    if((item is KeyValuePair<string,string>) && keyFormat == null )
                    {
                        var temp = (KeyValuePair <string, string>) item ;
                        key = temp.Key;
                        value = temp.Value;
                    }
                    else
                    {
                        List<string> arr = new List<string>();
                        keyFormat.Keys.Split(',').ToList().ForEach(col => { arr.Add(GetPropertyValue(item, col) + string.Empty); });
                        key = string.Format(keyFormat.Format, arr.ToArray());
                        value = JSONConverter.SerializeObject(item);
                    }

                    dataResult.Rows.Add(key, value);
                });
                return dataResult;
            }
            catch (Exception)
            {
                throw;
            }
        }
        /// <summary>
        /// Gets the Property Value from Object
        /// For Ex: AssetId.AssetTypeDefinitionId
        /// </summary>
        /// <param name="src">Object Data</param>
        /// <param name="propName">Property Name</param>
        /// <returns></returns>
        protected object GetPropertyValue(object src,string propName)
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
