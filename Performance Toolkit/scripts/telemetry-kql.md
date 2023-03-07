Read telemetry data for a sandbox

```
traces
| where timestamp > todatetime('2023-03-03T15:07:13Z')
| where timestamp <= todatetime('2023-03-03T15:24:34Z')
| where customDimensions.environmentName == 'NPRetailBCPT-Sandbox-5'
| where (customDimensions.eventId in ("RT0030", "AL0000DGF", "AL0000DHS", "AL0000DHR") or severityLevel == 3)
| order by timestamp desc
```

