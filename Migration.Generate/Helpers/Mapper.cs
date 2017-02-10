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
            Stopwatch st = new Stopwatch();
            st.Start();
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

            var tempResult = (Slapper.AutoMapper.MapDynamic(type, resultSet,false) as IEnumerable<T>).ToList();

            st.Stop();
            Trace.Write( st.Elapsed.ToString());
            return tempResult;
        }
    }
}
