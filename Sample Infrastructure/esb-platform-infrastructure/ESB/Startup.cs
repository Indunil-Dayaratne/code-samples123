using System;
using ESB.Authorisation;
using ESB.Models;
using ESB.Repositories;
using ESB.Services;
using Microsoft.ApplicationInsights.AspNetCore;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.ApplicationInsights.SnapshotCollector;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.AspNetCore.Server.IISIntegration;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.Net.Http.Headers;

namespace ESB
{
    public class Startup
    {
        public const string BEASApplication = "ESB";

        private class SnapshotCollectorTelemetryProcessorFactory : ITelemetryProcessorFactory
        {
            private readonly IServiceProvider _serviceProvider;

            public SnapshotCollectorTelemetryProcessorFactory(IServiceProvider serviceProvider) =>
                _serviceProvider = serviceProvider;

            public ITelemetryProcessor Create(ITelemetryProcessor next)
            {
                var snapshotConfigurationOptions = _serviceProvider.GetService<IOptions<SnapshotCollectorConfiguration>>();
                return new SnapshotCollectorTelemetryProcessor(next, configuration: snapshotConfigurationOptions.Value);
            }
        }

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            // Configure SnapshotCollector from application settings
            services.Configure<SnapshotCollectorConfiguration>(Configuration.GetSection(nameof(SnapshotCollectorConfiguration)));

            // Add SnapshotCollector telemetry processor.
            services.AddSingleton<ITelemetryProcessorFactory>(sp => new SnapshotCollectorTelemetryProcessorFactory(sp));

            services.AddApplicationInsightsTelemetry(Configuration);

            services.Configure<AzureStorageSettings>(Configuration.GetSection("AzureStorage"));
            services.Configure<AzureBusSettings>(Configuration.GetSection("AzureBus"));
            services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
            services.AddSingleton<IContainerCache, ContainerCache>();
            services.AddSingleton<IAzureRepository, AzureRepository>();
            services.AddSingleton<IBusSASTokenProviderFactory, BusSASTokenProviderFactory>();
            services.AddSingleton<ISASGenerator, SASGenerator>();
            services.AddSingleton<IHostedService, BlobCleanup>();

            // TODO: configure host names for CORS if required
            // services.AddCors();

            services.AddAuthentication(IISDefaults.AuthenticationScheme);
            services.AddMvc(config =>
            {
                var policy = new AuthorizationPolicyBuilder()
                    .RequireAuthenticatedUser()
                    .Build();
                config.Filters.Add(new AuthorizeFilter(policy));
            });

            services.AddBEASAuthorization(Configuration, BEASApplication);
            services.AddSingleton<IAuthorizationHandler, HasBEASAccess>();
            services.AddAuthorization(options =>
            {
                // to do a simple check of any of a list of claims you can just use RequireClaim
                // options.AddPolicy("ESB-ReadAll", policy => policy.RequireClaim("BEAS", "Admin", "Reader"));
                // However we need custom code to check whether the use has access to a specific queue or topic
                options.AddPolicy("ESB-Read", policy => policy.Requirements.Add(new AccessRequirement(AccessRequirement.AccessType.Read)));
                options.AddPolicy("ESB-Write", policy => policy.Requirements.Add(new AccessRequirement(AccessRequirement.AccessType.Write)));
                options.AddPolicy("ESB-Admin", policy => policy.RequireClaim("BEAS", "ESB_Admin"));
            });
            services.AddMemoryCache();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory logger, IConfiguration config)
        {
            logger.AddApplicationInsights(app.ApplicationServices, LogLevel.Debug);

            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
            }

            app.UseStaticFiles(new StaticFileOptions()
            {
                OnPrepareResponse = (context) => {
                    var headers = context.Context.Response.GetTypedHeaders();
                    headers.CacheControl = new CacheControlHeaderValue
                    {
                        MaxAge = config.GetValue<TimeSpan>("StaticFileCacheDuration")
                    };
                }
            });

            app.UseCors(builder => builder.WithOrigins("http://localhost:58603")
                .AllowCredentials()
                .AllowAnyMethod()
                .AllowAnyHeader());

            app.UseMvc();
        }
    }
}
