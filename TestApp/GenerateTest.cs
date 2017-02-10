using Migration.Generate;
using Migration.Generate.Generators;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Test.Generate
{
    [TestFixture(TestName = "Generate Test", Author = "Naresh")]
    public class GenerateTest
    {
        [Test]
        public void GenerateFactoryTest()
        {
            Assert.IsInstanceOf(typeof(GenericGenerator), GenerateFactory.GetGenerator("default"));
            Assert.IsInstanceOf(typeof(GenericGenerator), GenerateFactory.GetGenerator("XXX"));
        }
    }
}
