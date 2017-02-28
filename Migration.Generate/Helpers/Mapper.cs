using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Generate.Helpers
{
    public class Mapper
    {
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
            var mappedObject = (Slapper.AutoMapper.MapDynamic(type, resultSet,true) as IEnumerable<T>).ToList();
            return mappedObject;
        }
    }
}
