using Azure.Identity;
using AzureFunctions.Extensions.Swashbuckle;
using AzureFunctions.Extensions.Swashbuckle.Settings;
using BritServices.BearerTokenHelper.Services;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Hydration;
using EntrySheet.Api.Function.Services;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.OpenApi;
using Swashbuckle.AspNetCore.SwaggerGen;
using System;
using System.Diagnostics.CodeAnalysis;
using System.Reflection;
using EntrySheet.Api.Function.Clients;
using EntrySheet.Api.Function.Mappers;
using EntrySheet.Api.Function.Repositories;
using EntrySheet.Api.Function.Settings;

[assembly: FunctionsStartup(typeof(EntrySheet.Api.Function.Startup))]
namespace EntrySheet.Api.Function
{
    [ExcludeFromCodeCoverage]
    public class Startup : FunctionsStartup
    {
        private IServiceCollection _services;
        public override void Configure(IFunctionsHostBuilder builder)
        {
            _services = builder.Services;
            ConfigureServices();
            builder.AddSwashBuckle(Assembly.GetExecutingAssembly(), opts =>
            {
                opts.SpecVersion = OpenApiSpecVersion.OpenApi3_0;
                opts.AddCodeParameter = true;
                opts.PrependOperationWithRoutePrefix = true;
                opts.Documents = new[]
                {
                    new SwaggerDocument
                    {
                        Name = "v1",
                        Title = "Entry Sheet API",
                        Description = "This is the Swagger document for Entry Sheet API Endpoints",
                        Version = "v1"
                    }

                };
                opts.ConfigureSwaggerGen = x =>
                {
                    //custom operation example
                    x.CustomOperationIds(apiDesc => apiDesc.TryGetMethodInfo(out MethodInfo methodInfo)
                        ? methodInfo.Name
                        : Guid.NewGuid().ToString());
                };
            });
        }

        private void ConfigureServices()
        {
            _services.AddHttpClient("BritCacheService", client =>
            {
                client.BaseAddress = new Uri(Environment.GetEnvironmentVariable("britCache:BaseURL"));
            });

            _services.AddHttpClient("Beas", client =>
            {
                client.BaseAddress = new Uri(Environment.GetEnvironmentVariable("beas:BaseUrl"));
            });

            _services.AddTransient<IAuthenticationHelper, AuthenticationHelper>();
            _services.AddTransient<IHttpRequestHelper, HttpRequestHelper>();

            _services.AddSingleton<IKeyVaultHelper, KeyVaultHelper>();
            _services.AddSingleton<IBearerTokenHelper, BearerTokenHelper>();
            _services.AddSingleton<ITokenServiceHelper, TokenServiceHelper>();
            _services.AddSingleton<IAssemblyHelper, AssemblyHelper>();

            _services.AddTransient<IEclipseRiskApiClient, EclipseRiskApiClient>();
            _services.AddTransient<IEclipseRiskValidationApiClient, EclipseRiskValidationApiClient>();
            _services.AddTransient<IBritCacheClient, BritCacheClient>();
            _services.AddTransient<IEPlacingService, EPlacingService>();
            _services.AddSingleton<IIndustryCodeService, IndustryCodeService>();
            _services.AddSingleton<ISyndicateDataRetriever, SyndicateDataRetriever>();
            _services.AddSingleton<IRiskRatingService, RiskRatingService>();
            _services.AddSingleton<IEntrySheetDetailsRepository, EntrySheetDetailsRepository>();
            _services.AddTransient<ICurrencyService, CurrencyService>();

            _services.AddTransient<IEntrySheetService, EntrySheetService>();
            _services.AddTransient<IEntrySheetDetailsHydrator, EntrySheetDetailsHydrator>();
            _services.AddTransient<IPlacingHydrator, PlacingHydrator>();

            _services.AddOptions<BeasOptions>().Configure<IConfiguration>((settings, configuration) => configuration.GetSection("beas").Bind(settings));
            _services.AddOptions<EclipseRiskApiOptions>().Configure<IConfiguration>((settings, configuration) => configuration.GetSection("EclipseRisk").Bind(settings));
            _services.AddOptions<EclipseRiskValidationApiOptions>().Configure<IConfiguration>((settings, configuration) => configuration.GetSection("EclipseRiskValidation").Bind(settings));
            _services.AddOptions<BritCacheOptions>().Configure<IConfiguration>((settings, configuration) => configuration.GetSection("britCache").Bind(settings));
            _services.AddOptions<CosmosOptions>().Configure<IConfiguration>((settings, configuration) => configuration.GetSection("cosmos").Bind(settings));

            // Automapper
            var config = new AutoMapper.MapperConfiguration(cfg =>
            {
                cfg.AddProfile(new EntrySheetDetailsModelProfile());
            });

            AddKeyVaultSecrets();

            var mapper = config.CreateMapper();
            _services.AddSingleton(mapper);
        }
        private void AddKeyVaultSecrets()
        {
            var url = "https://" + Environment.GetEnvironmentVariable("KeyVaultName") + ".vault.azure.net";
            var configurationBuilder = new ConfigurationBuilder()
                    .AddAzureKeyVault(new Uri(url), new DefaultAzureCredential()).Build();

            _services.AddSingleton(provider =>
            {
                var keyVaultSecrets = configurationBuilder.Get<KeyVaultSecrets>();
                return keyVaultSecrets;
            });
        }
    }
}
