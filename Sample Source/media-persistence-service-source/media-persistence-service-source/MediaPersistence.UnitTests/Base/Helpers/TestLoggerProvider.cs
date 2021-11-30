using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;

namespace MediaPersistence.UnitTests.Base.Helpers
{
    [ExcludeFromCodeCoverage]
    public class TestLoggerProvider : ILoggerProvider
    {
        private readonly Func<string, LogLevel, bool> _filter;

        public TestLoggerProvider(Func<string, LogLevel, bool> filter = null)
        {
            _filter = filter;
        }

        private Dictionary<string, TestLogger> LoggerCache { get; } = new Dictionary<string, TestLogger>();

        public IEnumerable<TestLogger> CreatedLoggers => LoggerCache.Values;

        public ILogger CreateLogger(string categoryName)
        {
            if (!LoggerCache.TryGetValue(categoryName, out TestLogger logger))
            {
                logger = new TestLogger(categoryName, _filter);
                LoggerCache.Add(categoryName, logger);
            }

            return logger;
        }

        public IEnumerable<LogMessage> GetAllLogMessages() => CreatedLoggers.SelectMany(l => l.GetLogMessages()).OrderBy(p => p.Timestamp);

        public void ClearAllLogMessages()
        {
            foreach (TestLogger logger in CreatedLoggers)
            {
                logger.ClearLogMessages();
            }
        }

        public void Dispose()
        {
        }
    }
}
