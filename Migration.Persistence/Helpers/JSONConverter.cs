using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Persistence.Helpers
{
    public static class JSONConverter
    {
        public static string SerializeObject(object entity)
        {
             return JsonConvert.SerializeObject(entity);
        }
    }
}
