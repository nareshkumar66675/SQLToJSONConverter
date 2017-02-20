using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migration.Test
{
    public class GOT
    {
        public int Id { get; set; }
        public string CharacterName { get; set; }
        public string Role { get; set; }
        public string PlayedBy { get; set; }
        public int Age { get; set; }
        public House House { get; set; }
    }
    public class House
    {
        public int Id { get; set; }
        public string HouseName { get; set; }
        public string HouseMotto { get; set; }
    }
}
