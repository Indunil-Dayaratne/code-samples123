using System.Threading.Tasks;

namespace EntrySheet.Api.Function.Helpers
{
    public interface IKeyVaultHelper
    {
        Task<string> GetKeyVaultValueAsync(string key);
    }
}