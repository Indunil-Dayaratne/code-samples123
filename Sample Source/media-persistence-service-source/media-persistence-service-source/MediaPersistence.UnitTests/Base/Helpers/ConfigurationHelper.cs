using System.Diagnostics.CodeAnalysis;
using Microsoft.Extensions.Configuration;

namespace MediaPersistence.UnitTests.Base.Helpers
{
    [ExcludeFromCodeCoverage]
    public static class ConfigurationHelper
    {
        public static IConfigurationRoot GetIConfigurationRoot(string outputPath)
        {
            return new ConfigurationBuilder()
                .SetBasePath(outputPath)
                .AddJsonFile("appsettings.json", optional: true)
                .Build();
        }

        public static string GetSetting(IConfigurationRoot root, string settingName)
        {
            return root.GetSection(settingName).Value;

        }
    }
}
