using Migration.Configuration.ConfigObject;
using Migration.Persistence.Persistences.Search;
using Migration.Persistence.Persistences.SQL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Persistence
{
    public static class PersistenceFactory
    {
        /// <summary>
        /// Used to get Persistence Type based on Group name and Process Type
        /// </summary>
        /// <param name="component">Component</param>
        /// <returns>Persistence Instance</returns>
        public static IPersistence GetPersistenceType(Component component)
        {
            //if (component.GroupName== Common.GroupType.REPORT)
            //{
            //    switch (component.PersistType.ToUpper())
            //    {
            //        case "DEFAULT":
            //            return new ElasticGenericPersistence();
            //        default:
            //            return new ElasticGenericPersistence();
            //    }
            //}
            //else    
            //{
                switch (component.PersistType.ToUpper())
                {
                    case "DEFAULT":
                        return new SqlGenericPersistence();
                    default:
                        return new SqlGenericPersistence();
                }
            //}
        }
    }
}
