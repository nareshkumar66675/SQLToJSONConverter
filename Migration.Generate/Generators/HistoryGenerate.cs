using Migration.Common;
using Migration.Configuration;
using Migration.Configuration.ConfigObject;
using Migration.Generate.Helpers;
using Migration.ProcessQueue;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Migration.Generate.Generators
{
    class HistoryGenerator: GenericGeneratorWtParams
    {
        private BlockingCollection<dynamic> Queue = new BlockingCollection<dynamic>();
        public override string GetSourceQuery(string componentName)
        {
            return Configurator.GetSourceByComponentName(componentName);
        }
        /// <summary>
        /// Generates Entities from Old Data and adds it to the Process Queue
        /// </summary>
        /// <param name="component">Component Details</param>
        /// <returns>True, is Success else False.</returns>
        public override bool Generate(Component component)
        {
            DateTime startTime = DateTime.Now;
            Mapper mapper = new Mapper();
            List<UniqueColumn> customIdentifiers = new List<UniqueColumn>();
            try
            {
                //Get Entity Type
                Type entityType = Type.GetType(component.DomainType);

                if (entityType == null)
                    throw new Exception("Error in Domain Type -" + component.DomainType);



                //long siteID;
                //if (!long.TryParse(Configurator.GetQueryParams(component.Name).FirstOrDefault(), out siteID))
                //    throw new FormatException("SiteID is not valid");

                //SqlOperation.LoadHistoryData(siteID);


                var generate =Task.Factory.StartNew(() => GenerateData(component.Name));
                var process = Task.Factory.StartNew(() => ProcessData(component, entityType));

                generate.Wait();
                process.Wait();

                //NotifyGenerateStatus(resultSet, resultEntities, component, startTime, Status.Running.GetDescription());


                return true;
            }
            catch (Exception ex)
            {
                //NotifyGenerateStatus(resultSet, resultEntities, component, startTime, Status.Failed.GetDescription());
                throw;
            }
        }
        private void ProcessData(Component component, Type entityType)
        {
            List<UniqueColumn> customIdentifiers = new List<UniqueColumn>();
            List<object> resultEntities = null;
            Mapper mapper = new Mapper();

            //Get Custom Identifiers - If any
            customIdentifiers = Configuration.Configurator.GetUniqueColumns(component.Name);
            while (!Queue.IsCompleted)
            {
                dynamic resultSet = null;
                Queue.TryTake(out resultSet, 5000);
                if(resultSet!=null)
                {
                    //Map Column Names
                    resultSet = MapColumns(component.Name, resultSet);
                    //Map Data to Entity
                    resultEntities = mapper.Map<object>(resultSet, entityType, customIdentifiers);
                    Logger.Instance.LogInfo($"Process Data Memory Usage {GC.GetTotalMemory(false) / 1024 / 1024} Queue Count - {Queue.Count}");
                    if (Queue.IsAddingCompleted && Queue.Count == 0)
                        ProcessQueue.ProcessQueue.Processes.TryAdd(new ProcessItem(component, resultEntities, ItemsType.PartialEnd));
                    else
                        //Add to Process Queue for Persisting
                        ProcessQueue.ProcessQueue.Processes.TryAdd(new ProcessItem(component, resultEntities, ItemsType.Partial));
                }
            }
        }
        private List<List<string>> GetAssetLists()
        {
            var historyIdList = SqlOperation.GetAllHistoryID();
            List<List<string>> assets = new List<List<string>>();
            List<string> temp = new List<string>();
            long sum = 0;
            foreach (var item in historyIdList)
            {
                if (item.Value >= 20000)
                {
                   assets.Add(new List<string>() { item.Key });
                }
                else
                {
                    sum += item.Value;
                    if(sum<20000)
                    {
                        temp.Add(item.Key);
                    }
                    else
                    {
                        assets.Add(temp);
                        sum = item.Value;
                        temp = new List<string>();
                        temp.Add(item.Key);
                    }
                }
            }
            return assets;
        }
        private void GenerateData(string componentName)
        {
            var historyIdList = SqlOperation.GetAllHistoryID().Select(t=>t.Key).ToList();

            //var result = historyIdList.Aggregate(
            //new { Sum = (long)0, List = new List<List<string>>() },
            //(data, value) =>
            //    {
            //        long sum = data.Sum + value.Value;
            //        if (data.List.Count > 0 && sum <= 64009)
            //            data.List[data.List.Count - 1].Add(value.Key);
            //        else
            //            data.List.Add(new List<string> { (sum = value.Value) });
            //        return new { Sum = sum, List = data.List };
            //    },
            //    data => data.List)
            //.ToList();
            GetAssetLists();
            List<string> templist = new List<string>();
            dynamic resultSet = null;
            int count = 0;
            //Get Data From Legacy/Old Database
            var query = GetSourceQuery(componentName);
            Dictionary<string, string> var = new Dictionary<string, string>();
            //var.a
            for (int i = 0; i < historyIdList.Count; i++)
            {
                count++;
                templist.Add(historyIdList[i]);
                if (count == 5 || historyIdList.Count==i)
                {
                    resultSet = SqlOperation.ExecuteQueryOnSource(string.Format(query, string.Join(",", templist)));
                    Logger.Instance.LogInfo($"Generate Data Memory Usage {GC.GetTotalMemory(false) / 1024 / 1024} Queue Count - {Queue.Count}");
                    Queue.TryAdd(resultSet, 500);
                    count = 0;
                    templist.Clear();
                }
            }
            Queue.CompleteAdding();

            //foreach (var item in historyIdList)
            //{
            //    count++;
            //    templist.Add(item);
            //    if(count==10)
            //    {
            //        resultSet = SqlOperation.ExecuteQueryOnSource(string.Format(query,string.Join(",",templist)));
            //        Queue.TryAdd(resultSet,500);
            //        count = 0;
            //    }
            //}

        }
    }
}
