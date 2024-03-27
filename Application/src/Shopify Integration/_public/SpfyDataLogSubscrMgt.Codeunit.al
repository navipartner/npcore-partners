#if not BC17
codeunit 6184825 "NPR Spfy Data Log Subscr. Mgt."
{
    Access = Public;

    procedure AddDataLogSetupEntity(IntegrationArea: Enum "NPR Spfy Integration Area"; TableId: Integer; LogInsertion: Integer; LogModification: Integer; LogDeletion: Integer; KeepLogFor: Duration)
    var
        SpfyDataLogSubscrMgt: Codeunit "NPR Spfy DLog Subscr.Mgt.Impl.";
    begin
        SpfyDataLogSubscrMgt.AddDataLogSetupEntity(IntegrationArea, TableId, LogInsertion, LogModification, LogDeletion, KeepLogFor);
    end;
}
#endif