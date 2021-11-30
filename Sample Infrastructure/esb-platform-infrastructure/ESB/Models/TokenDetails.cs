﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Models
{
    public class TokenDetails
    {
        public string Url { get; set; }
        public string SASToken { get; set; }
        public DateTimeOffset Expires { get; set; }
    }
}
