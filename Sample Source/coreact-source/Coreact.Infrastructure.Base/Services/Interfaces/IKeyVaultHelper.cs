using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Coreact.Infrastructure.Base.Services
{
    public interface IKeyVaultHelper
    {
        Task<string> GetKeyVaultValue(string key);

        string RESOURCEID { get;}
    }
}
