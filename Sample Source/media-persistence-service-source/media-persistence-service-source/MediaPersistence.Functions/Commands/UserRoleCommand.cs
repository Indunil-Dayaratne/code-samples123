using System;
using System.Collections.Generic;
using System.Text;

namespace MediaPersistence.Functions.Commands
{
    public class UserRoleCommand
    {
        public string ApplicationName { get; set; }

        public string ApplicationAreaName { get; set; }

        public string RoleName { get; set; }

        public string UserPrincipalName { get; set; }
    }
}
