using System.Threading.Tasks;

namespace EntrySheet.WebApp.Helpers
{
    public interface IKeyVaultHelper
    {
        Task<string> GetKeyVaultValueAsync(string key);
    }
}
