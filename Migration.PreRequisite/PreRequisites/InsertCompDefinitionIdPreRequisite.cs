using Migration.PreRequisite.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.PreRequisite.PreRequisites
{
    public class InsertCompDefinitionIdPreRequisite : IPreRequisite
    {
        private const string _name = "InsertCompDefinitionId";
        private readonly string _connetionString = string.Empty;
        public InsertCompDefinitionIdPreRequisite(string connectionString)
        {
            _connetionString = connectionString;
        }
        public string Name => _name;

        public bool Execute()
        {
            return SqlOperation.InsertComponentDefinition(_connetionString);
        }
    }
}
