using System.Diagnostics.CodeAnalysis;
using Autofac;
using FunctionAppHelper.Repository;
using FunctionAppHelper.Services;
using FunctionAppHelper.Services.Interfaces;
using FunctionAppHelper.Validators;
using MediaPersistence.Functions.Helpers;
using MediaPersistence.Functions.Helpers.Interfaces;
using MediaPersistence.Functions.Repositories;

namespace MediaPersistence.Functions
{
    [ExcludeFromCodeCoverage]
    public class ServicesModule : Module
    {
        protected override void Load(ContainerBuilder builder)
        {
            builder.RegisterInstance<IFunctionCache>(new FunctionCache());
            builder.RegisterType<ServiceHelper>().As<IServiceHelper>().SingleInstance();
            builder.RegisterType<BearerTokenValidator>().As<IBearerTokenValidator>().SingleInstance();
            builder.RegisterType<FunctionRepository>().As<IFunctionRepository>().SingleInstance();
            builder.RegisterType<KeyVaultHelper>().As<IKeyVaultHelper>().SingleInstance();
            builder.RegisterType<AuthenticationHelper>().As<IAuthenticationHelper>().SingleInstance();
            builder.RegisterType<MediaRepository>().As<IMediaRepository>().SingleInstance();
            builder.RegisterType<BlobStorageHelper>().As<IBlobStorageHelper>().SingleInstance();
        }
    }
}