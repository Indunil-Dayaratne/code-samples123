
using Coreact.Infrastructure.Base.Services;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Text;

namespace Coreact.Infrastructure.Base.Repository
{
    public class FunctionRepository : IFunctionRepository
    {
        private readonly IServiceHelper _serviceHelper;
        private readonly IFunctionCache _functionCache;
        private readonly ILogger _logger;
        private readonly IBearerTokenValidator _tokenValidator;

        public FunctionRepository(ILogger logger,IServiceHelper sHelper,IFunctionCache fCache,IBearerTokenValidator tokenValidator)
        {
            _logger = logger;
            _serviceHelper = sHelper;
            _functionCache = fCache;
            _tokenValidator = tokenValidator;
        }

        public ILogger Logger { get { return _logger; } }
        public IFunctionCache FunctionCache { get { return _functionCache; } }
        public IServiceHelper ServiceHelper { get { return _serviceHelper; } }

        public IBearerTokenValidator BearerTokenValidator { get { return _tokenValidator; } }
    }
}
