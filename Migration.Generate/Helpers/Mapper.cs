using Migration.Common;
using Migration.Configuration.ConfigObject;
using Newtonsoft.Json;
using Slapper;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Slapper.AutoMapper.Configuration;

namespace Migration.Generate.Helpers
{
    public class Mapper
    {
        /// <summary>
        /// Maps ResultSet to Entities using Slapper.Automapper
        /// </summary>
        /// <typeparam name="T">Entity Result Type</typeparam>
        /// <param name="resultSet">Data</param>
        /// <param name="type">Type of Entity</param>
        /// <returns>List of Mapped Data</returns>
        public List<T> Map<T>(dynamic resultSet,Type type)
        {
            //var obj = (object)resultSet;
            //List<T> result = new List<T>();
            //var temp =(obj as List<object>).Select((x, i) => new { Index = i, Value = x })
            //.GroupBy(x => x.Index / 10000)
            //.Select(x => x.Select(v => v.Value).ToList())
            //.ToList();
            //foreach(var item in temp)
            //{
            //    var tempResult = Slapper.AutoMapper.MapDynamic(type, item);
            //    result.AddRange(tempResult as IEnumerable<T>);
            //}

            var mappedObject = MapObject<T>(resultSet, type, null);
            //AutoMapper.Cache.ClearAllCaches();
            return mappedObject;
        }
        /// <summary>
        /// Maps ResultSet to Entities using Slapper.Automapper
        /// </summary>
        /// <typeparam name="T">Entity Result Type</typeparam>
        /// <param name="resultSet">Data</param>
        /// <param name="type">Type of Entity</param>
        /// <param name="Identifiers">List of Custom Identifiers</param>
        /// <returns>List of Mapped Data</returns>
        public List<T> Map<T>(dynamic resultSet, Type type,List<UniqueColumn> Identifiers)
        {
            var mappedObject = MapObject<T>(resultSet,type,Identifiers);

            return mappedObject;
        }
        #region PrivateMethods
        private void SetDictionaryConverter()
        {
            var dictConverter = new DictionaryConverter();
            if (!TypeConverters.Contains(dictConverter))
            {
                TypeConverters.Add(dictConverter);
            }
        }
        private List<T> MapObject<T>(dynamic resultSet, Type type, List<UniqueColumn> Identifiers, bool setCustomDictionary = true)
        {
            if (type == null)
                throw new ArgumentNullException("Type is Null");

            //Set Custom Dictionary Converter
            if (setCustomDictionary)
                SetDictionaryConverter();

            //Add Custom Identifiers
            AddCustomIdentifiers(Identifiers);
            Stopwatch sw = new Stopwatch();
            sw.Start();

            //Map Objects to Entities
            var mappedObject = (AutoMapper.MapDynamic(type, resultSet, false) as IEnumerable<T>).ToList();
            sw.Stop();
            Logger.Instance.LogInfo($"Mapping Completed {sw.Elapsed.ToString(@"hh\:mm\:ss\.fff")}. Memory Usage {GC.GetTotalMemory(false) / 1024 / 1024}");

            return mappedObject;
        } 
        private void AddCustomIdentifiers(List<UniqueColumn> Identifiers)
        {
            if (Identifiers != null && Identifiers.Count > 0)
            {
                Identifiers.ForEach(identifier =>
                {
                    Type idType = Type.GetType(identifier.Type);

                    if (idType == null)
                        throw new Exception("Custom Id Type not Found:" + identifier.Type);

                    if(identifier.Column != null && identifier.Column.Count > 0)
                        AddIdentifiers(idType, identifier.Column);
                });
            }
        }
        #endregion
    }
    /// <summary>
    /// Dictionary Converter - Converts Json Data to Dictionary Object
    /// </summary>
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
}
