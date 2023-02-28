Read telemetry data for a sandbox

```
traces
| where timestamp > ago(30min)
| where customDimensions.environmentName == "NPRetailBCPT-Sandbox-2"
| order by timestamp desc
```

