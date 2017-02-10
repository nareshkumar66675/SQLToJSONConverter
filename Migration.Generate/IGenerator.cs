using Migration.Configuration.ConfigObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Generate
{
    public interface IGenerator
    {
        /// <summary>
        /// Generates Items from Exisiting/Old Database
        /// </summary>
        /// <param name="component">Component Details</param>
        /// <returns>True, if success else False</returns>
        bool Generate(Component component);
    }
}
