# Telemetry

In AL we can emit custom telemetry trace signals to Azure Application Insights. Some general guidelines:

- The eventId should start with NPR (followed by the PTE). (BC will prefix that name with AL.)

    Example: NPR_ or NPR_AZ_

- The eventId should be unique. If you are unsure, add a GUID value. Attaching a GUID to the event id will make it easy to find when searching the code.

    Example: NPR_ReportBugAndThrowError or NPR_AZ_1adbfbf9-2a50-4176-af39-c074352bfc1b

- Telemetry can be categorized in verbosity 5 levels - critical and verbose should be reserved for special usage.
    1) **Critical** - application type errors. We should not have any critical errors in production. These will be listed on a dashboard and you will get a case if they occur;
    2) **Error** - is related to usage patterns;
    3) **Warning** - is related to usage patterns;
    4) **Normal** - is related to usage patterns;
    5) **Verbose** - verbose level can be turned on for a limit amount of time, so you could litter the code with these events;

There will be a significant amount of noise for levels Error, Warning, and Normal making it difficult to find actual errors, but it will reveal usage patterns and can report data volume. 

> [!NOTE]
> In runtime 8.0 (BC19 online) there is new a datatype, ErrorInfo, that will make emitting errors to telemetry even more convenient.

### NPRetail is setup to emit generic telemetry on the following eventId's:

- **ALNPR_ImportList** - Import List;
- **ALNPR_PosAction** - POS Actions;
- **ALNPR_ReportBugAndThrowError** - Frontend Error Messages;
- **ALNPR_TaskList** - Task List;

#### ALNPR_Import List

This data is close to a mirror of the **Import List** data in BC and shows the inbound message from, for example, our web. Basically all data except the actual message body is emitted to this log. The custom dimension **NPR_Nc_ImportType** will give us insight on the specific message types and frequency.

#### ALNPR_PosActions
This log captures interactions made by a user from the POS. The log includes custom dimension **NPR_SessionUniqId** which should allow us back-track the sequence of events leading up to an error.

#### ALNPR_ReportBugAndThrowError

This log captures error message from the POS workflow engine. For example, the messages in the displayed in the orange "toaster" bottom right. The log includes custom dimension **NPR_SessionUniqId** which should allow us back-track the sequence of events leading up to an error using the **POS Action** event log.

#### ALNPR_Task List

This data is close to a mirror of the **Task List** data in BC and shows the outbound message from our BC to, for example, Magento. Basically all data except the actual message body is emitted to this log. The custom dimension **NPR_TL_Type** will give us insight on the specific message types and frequency.

## Related Links
- [Creating Custom Telemetry Traces for Application Insights Monitoring](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-instrument-application-for-telemetry-app-insights)
- [ErrorInfo Data Type](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/errorinfo/errorinfo-data-type)
