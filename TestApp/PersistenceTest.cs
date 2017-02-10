using Migration.Configuration.ConfigObject;
using Migration.Persistence;
using Migration.Persistence.Persistences.Search;
using Migration.Persistence.Persistences.SQL;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Test
{
    [TestFixture(TestName ="Persistence Test",Author ="Naresh")]
    public class PersistenceTest
    {
        [Test]
        public void PersistenceFactoryTest()
        {
            Component comp = new Component();
            comp.PersistType = "default";
            comp.GroupName = Common.GroupType.AUTH;
            Assert.IsInstanceOf(typeof(SqlGenericPersistence), PersistenceFactory.GetPersistenceType(comp));
            comp.GroupName = Common.GroupType.ASSET;
            Assert.IsInstanceOf(typeof(SqlGenericPersistence), PersistenceFactory.GetPersistenceType(comp));
            comp.GroupName = Common.GroupType.SEARCH;
            Assert.IsInstanceOf(typeof(ElasticGenericPersistence), PersistenceFactory.GetPersistenceType(comp));
        }
    }
}
