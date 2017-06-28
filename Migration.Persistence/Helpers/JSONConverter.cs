using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Persistence.Helpers
{
    /// <summary>
    /// Json Converter
    /// </summary>
    public static class JSONConverter
    {
        /// <summary>
        /// Serializes and Object to JSON - Newtonsoft
        /// </summary>
        /// <param name="entity"></param>
        /// <returns></returns>
        public static string SerializeObject(object entity)
        {
             return JsonConvert.SerializeObject(entity);
        }
    }
}
