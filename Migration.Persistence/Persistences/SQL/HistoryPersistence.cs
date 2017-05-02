using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Migration.ProcessQueue;
using Migration.Configuration;
using Migration.Persistence.Helpers;
using static Migration.Common.Common;
using Migration.Common;

namespace Migration.Persistence.Persistences.SQL
{
    /// <summary>
    /// To Persist Asset History Data
    /// </summary>
    public class HistoryPersistence:SqlGenericPersistence,IPersistence
    {
        public override bool Insert(ProcessItem item)
        {
            try
            {
                var table = ConvertToCommonDataTable(item.Items, Configurator.GetKeyFormat(item.Component.Name));
                //Insert to History Database
                var historyCopy= Task.Factory.StartNew(() => SqlOperation.ExecuteBulkCopy(table, item.Component.GroupName, Configurator.GetDestinationByComponentName(item.Component.Name)));
                //Insert to Asset Database
                var assetCopy = Task.Factory.StartNew(() => SqlOperation.ExecuteBulkCopy(table, GroupType.ASSET, Configurator.GetDestinationByComponentName(item.Component.Name)));

                //Wait for both the process
                historyCopy.Wait();
                assetCopy.Wait();

                if (AppSettings.IsReportEnabled)
                    SqlOperation.UpdatePersistReport(item.Component.Name, DateTime.Now, item.Items.Count, item.Component.GroupName, Status.Success.GetDescription());

                return true;
            }
            catch (Exception ex)
            {
                if (AppSettings.IsReportEnabled)
                    SqlOperation.UpdatePersistReport(item.Component.Name, DateTime.Now, item.Items.Count, item.Component.GroupName, Status.Failed.GetDescription());
                Logger.Instance.LogError($"Error Occurred While Inserting Item : {item.Component.Name}", ex);
                return false;
            }
        }
    }
}
