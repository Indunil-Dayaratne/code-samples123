using System;
using System.Collections.Generic;
using System.Text;
using Autofac;
using Coreact.CoreProcesser.Function.Services;
using Microsoft.Extensions.Logging;
using AutofacOnFunctions.Services.Ioc;
using Microsoft.Extensions.DependencyInjection;
using Coreact.CoreProcesser.Function.Repository;
using Microsoft.Azure.WebJobs.Extensions.Http;


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
            builder.RegisterInstance<IFunctionCache>(new FunctionCache());
            builder.RegisterType<ServiceHelper>().As<IServiceHelper>().SingleInstance();
            builder.RegisterType<KeyVaultHelper>().As<IKeyVaultHelper>().SingleInstance();
            builder.RegisterType<BearerTokenValidator>().As<IBearerTokenValidator>().SingleInstance();
            builder.RegisterType<FunctionRepository>().As<IFunctionRepository>();
        }
    }
}
