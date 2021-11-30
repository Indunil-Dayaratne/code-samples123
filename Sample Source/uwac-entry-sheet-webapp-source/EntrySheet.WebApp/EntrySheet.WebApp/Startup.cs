using BritServices.BearerTokenHelper.Services;
using EntrySheet.WebApp.Filters;
using EntrySheet.WebApp.Helpers;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;

namespace EntrySheet.WebApp
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddApplicationInsightsTelemetry(Configuration);
            services.AddControllersWithViews();
            services.Configure<Settings>(Configuration.GetSection("Settings"));
            services.Configure<BeasOptions>(Configuration.GetSection("Settings:Beas"));
            services.Configure<EntrySheetApi>(Configuration.GetSection("Settings:EntrySheetApi"));
            services.Configure<PbqaApi>(Configuration.GetSection("Settings:PbqaApi"));
            services.Configure<IgnisApi>(Configuration.GetSection("Settings:IgnisApi"));
            services.AddMemoryCache();
            services.AddHttpClient()
              .AddSingleton<IFingerprint, Fingerprint>()
              .AddSingleton<IHttpRequestHelper, HttpRequestHelper>()
              .AddSingleton<IKeyVaultHelper, KeyVaultHelper>()
              .AddSingleton<IAuthenticationHelper, AuthenticationHelper>()
              .AddSingleton<IBearerTokenHelper, BearerTokenHelper>()
              .AddScoped<AuthenticationFilter>(); 

            Environment.SetEnvironmentVariable("Audience", Configuration["AzureAd:Audience"]);
            Environment.SetEnvironmentVariable("ValidIssuers", Configuration["AzureAd:ValidIssuers"]);
            Environment.SetEnvironmentVariable("OpenIdConfigurationEndPoint", Configuration["AzureAd:OpenIdConfigurationEndPoint"]);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                var cors = Configuration["Cors:Urls"].Split(',');
                app.UseCors(builder => builder.WithOrigins(cors)
                    .AllowCredentials()
                    .AllowAnyMethod()
                    .AllowAnyHeader());
            }
            else
            {
                app.UseExceptionHandler("/Home/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }
            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller=Home}/{action=Index}/{id?}");
            });
        }
    }
}
