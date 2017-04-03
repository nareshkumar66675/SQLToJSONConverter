﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Migration.Common.Common;

namespace Migration.Generate.Generators
{
    class AuthReportData : GenerateData
    {
        public override string GetConnectionString()
        {
            return ConnectionStrings.AuthConnectionString;
        }
    }
}