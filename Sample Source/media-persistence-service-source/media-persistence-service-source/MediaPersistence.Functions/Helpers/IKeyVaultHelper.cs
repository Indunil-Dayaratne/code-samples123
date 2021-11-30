using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace MediaPersistence.Functions.Helpers.Interfaces
{
    public interface IKeyVaultHelper
    {
        Task<string> GetKeyVaultValueAsync(string key);
        string ResourceId { get; }
    }
}
