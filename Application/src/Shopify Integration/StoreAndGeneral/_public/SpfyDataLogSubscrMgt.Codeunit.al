#if not BC17
codeunit 6184825 "NPR Spfy Data Log Subscr. Mgt."
{
    Access = Public;

    /// <summary>
    /// Registers a BC table for Shopify-driven data-log capture and subscribes the Shopify data
    /// processor to changes on it. After this call:
    ///   - an NPR Data Log Setup (Table) row exists for the table with the requested logging levels,
    ///   - an NPR Data Log Subscriber row links the table to the Shopify data-processing handler,
    ///   - extensions can refine the subscriber via SpfyIntegrationEvents.OnSetupDataLogSubsriberDataProcessingParams.
    /// If a setup row already exists, the existing logging levels are widened (never narrowed) to
    /// satisfy the requested levels — multiple integration areas can safely register the same table.
    /// Use this from PTEs/extensions that add their own Shopify-bound tables and need the data log
    /// to capture changes so the Shopify NcTask scheduler picks them up.
    /// </summary>
    /// <param name="IntegrationArea">The Shopify integration area driving this subscription. Used by the OnSetupDataLogSubsriberDataProcessingParams publisher to let extensions customise per-area behaviour.</param>
    /// <param name="TableId">BC table whose changes should be data-logged.</param>
    /// <param name="LogInsertion">Logging level for inserts. Pass one of the NPR Data Log Setup (Table)."Log Insertion" option values: 0=" " (off), 1=Simple, 2=Detailed.</param>
    /// <param name="LogModification">Logging level for modifications. Pass one of the "Log Modification" option values: 0=" " (off), 1=Simple, 2=Detailed, 3=Changes (per-field deltas).</param>
    /// <param name="LogDeletion">Logging level for deletes. Pass one of the "Log Deletion" option values: 0=" " (off), 1=Simple, 2=Detailed.</param>
    /// <param name="KeepLogFor">Retention duration before the BC data-log cleanup job purges old entries (e.g. JobQueueManagement.DaysToDuration(7) for a week).</param>
    procedure AddDataLogSetupEntity(IntegrationArea: Enum "NPR Spfy Integration Area"; TableId: Integer; LogInsertion: Integer; LogModification: Integer; LogDeletion: Integer; KeepLogFor: Duration)
    var
        SpfyDataLogSubscrMgt: Codeunit "NPR Spfy DLog Subscr.Mgt.Impl.";
    begin
        SpfyDataLogSubscrMgt.AddDataLogSetupEntity(IntegrationArea, TableId, LogInsertion, LogModification, LogDeletion, KeepLogFor);
    end;
}
#endif