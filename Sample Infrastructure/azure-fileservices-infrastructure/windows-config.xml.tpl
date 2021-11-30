<WadCfg>
    <DiagnosticMonitorConfiguration overallQuotaInMB="5120">
    <DiagnosticInfrastructureLogs scheduledTransferPeriod="PT1M" scheduledTransferLogLevelFilter="Warning"/>
    
    <PerformanceCounters scheduledTransferPeriod="PT1M">

        <PerformanceCounterConfiguration counterSpecifier="\Memory\% Committed Bytes In Use" sampleRate="PT60S" unit="percent"/>

        <PerformanceCounterConfiguration counterSpecifier="\LogicalDisk(_Total)\% Free Space" sampleRate="PT60S" unit="percent"/>

    </PerformanceCounters>

    <WindowsEventLog scheduledTransferPeriod="PT1M">
        <DataSource name="Application!*[System[(Level = 1 or Level = 2)]]"/>

        <DataSource name="Security!*[System[(Level = 1 or Level = 2)]"/>

        <DataSource name="System!*[System[(Level = 1 or Level = 2)]]"/>
    </WindowsEventLog>
    <Metrics resourceId="%VirtualMachineResourceId%">

        <MetricAggregation scheduledTransferPeriod="PT1H"/>

        <MetricAggregation scheduledTransferPeriod="PT1M"/>

    </Metrics>
    </DiagnosticMonitorConfiguration>
</WadCfg>