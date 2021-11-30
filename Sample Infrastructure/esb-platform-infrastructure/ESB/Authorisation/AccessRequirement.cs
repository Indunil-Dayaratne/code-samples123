using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Authorisation
{
    public class AccessRequirement : IAuthorizationRequirement
    {
        public enum AccessType { Read, Write };
        public AccessType AccessRequired { get; private set; }

        public AccessRequirement(AccessType accessType)
        {
            AccessRequired = accessType;
        }
    }
}
