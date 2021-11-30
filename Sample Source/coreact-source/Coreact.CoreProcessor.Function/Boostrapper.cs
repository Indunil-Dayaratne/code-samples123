using System;
using System.Collections.Generic;
using System.Text;
using Autofac;
using Microsoft.Extensions.Logging;
using AutofacOnFunctions.Services.Ioc;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Coreact.Infrastructure.Base.Repository;
using Coreact.Infrastructure.Base.Services;

namespace Coreact.CoreProcesser.Function
{
    public class FunctionStartup : IBootstrapper
    {
        public const AuthorizationLevel DEFAULT_AUTHORIZATIONLEVEL = AuthorizationLevel.Anonymous;

        public Module[] CreateModules()
        {
            return new Module[]
            {
                new ServicesModule()
            };
        }
    }

    public class ServicesModule : Module
    {
        protected override void Load(ContainerBuilder builder)
        {
            builder.RegisterType<FunctionCache>().As<IFunctionCache>().SingleInstance();
            builder.RegisterType<ServiceHelper>().As<IServiceHelper>().SingleInstance();
            builder.RegisterType<KeyVaultHelper>().As<IKeyVaultHelper>().SingleInstance();
            builder.RegisterType<BearerTokenValidator>().As<IBearerTokenValidator>().SingleInstance();
            builder.RegisterType<FunctionRepository>().As<IFunctionRepository>();
        }
    }
}
