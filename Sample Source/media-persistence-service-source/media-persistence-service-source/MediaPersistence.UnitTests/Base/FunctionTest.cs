using System.Diagnostics.CodeAnalysis;
using MediaPersistence.UnitTests.Base.Helpers;

namespace MediaPersistence.UnitTests.Base
{
    [ExcludeFromCodeCoverage]
    public abstract class FunctionTest
    {
        public TestLogger log = new TestLogger("Test");
    }
}
