using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Reflection;

namespace EntrySheet.Api.Function.Helpers
{
    [ExcludeFromCodeCoverage]
    public class AssemblyHelper: IAssemblyHelper
    {
        public string GetLocationOfExecutingAssembly()
        {
            return Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), @"..\");
        }

    }
}
