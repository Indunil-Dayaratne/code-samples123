using System.Diagnostics.CodeAnalysis;
using Autofac;
using AutofacOnFunctions.Services.Ioc;

namespace MediaPersistence.Functions
{
    [ExcludeFromCodeCoverage]
    public class FunctionStartup : IBootstrapper
    {
        public Module[] CreateModules()
        {
            return new Module[]
            {
                new ServicesModule()
            };
        }
    }
}