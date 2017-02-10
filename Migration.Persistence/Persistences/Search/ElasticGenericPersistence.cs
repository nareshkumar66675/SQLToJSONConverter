using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Migration.Configuration.ConfigObject;
using Migration.ProcessQueue;

namespace Migration.Persistence.Persistences.Search
{
    public class ElasticGenericPersistence : IPersistence
    {
        public bool Insert(ProcessItem item)
        {
            throw new NotImplementedException();
        }
    }
}
