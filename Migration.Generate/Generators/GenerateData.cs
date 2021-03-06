﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Migration.Configuration.ConfigObject;
using Migration.Generate.Helpers;
using Migration.ProcessQueue;
using System.Data;
using static Migration.Common.Common;
using Migration.Common;

namespace Migration.Generate.Generators
{
    /// <summary>
    /// Generates Object from Sql Tables
    /// </summary>
    public abstract class GenerateData:GenericGenerator
    {
        /// <summary>
        /// Connection String
        /// </summary>
        /// <returns> Connection String</returns>
        public abstract string GetConnectionString();
        /// <summary>
        /// Generates object from Sql Table JSON Data
        /// </summary>
        /// <param name="component"></param>
        /// <returns></returns>
        public override bool Generate(Component component)
        {
            DateTime startTime = DateTime.Now;
            dynamic resultSet = null;
            try
            {
                //Get Data From  Database
                var query = GetSourceQuery(component.Name);
                resultSet = ConvertToKeyValue(SqlOperation.ExecuteQuery(GetConnectionString(),query));

                //Notify Status
                NotifyGenerateStatus(resultSet, resultSet, component, startTime, Status.Running.GetDescription());

                //Add to Process Queue for Persisting
                ProcessQueue.ProcessQueue.Processes.TryAdd(new ProcessItem(component, resultSet),1000);

                return true;
            }
            catch (Exception)
            {
                NotifyGenerateStatus(resultSet, resultSet, component, startTime, Status.Failed.GetDescription());
                throw;
            }
        }
        /// <summary>
        /// Updates Report Table. If Settings allow.
        /// </summary>
        /// <param name="src">Source Data</param>
        /// <param name="result">Mapped Data</param>
        /// <param name="component">Component</param>
        /// <param name="startTime">Generation Start Time</param>
        /// <param name="status">Status of Generation</param>
        protected new void NotifyGenerateStatus(dynamic src, dynamic result, Component component, DateTime startTime, string status)
        {
            if (AppSettings.IsReportEnabled)
            {
                var totRecordCount = (src as IEnumerable<object>)?.Count();
                var totUniqueRecordCount = (result as IEnumerable<object>)?.Count();
                SqlOperation.InsertGenerateReport(component.Name, startTime, DateTime.Now, totRecordCount ?? 0, totUniqueRecordCount ?? 0, component.GroupName, status);
            }
        }
        private List<object> ConvertToKeyValue(DataTable rsltTable)
        {
            List<object> rsltList = new List<object>();

            var temp = rsltTable.AsEnumerable().Select(t => new KeyValuePair<string, string>(t.Field<string>(0), t.Field<string>(1)));

            temp.ToList().ForEach(t =>
            {
                rsltList.Add(t);
            });

            return rsltList; ;
        }
    }
}
