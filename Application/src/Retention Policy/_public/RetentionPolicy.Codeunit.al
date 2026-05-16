#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248683 "NPR Retention Policy"
{
    procedure UpsertTablePolicyV2(TableId: Integer; var RetentionPolicyEnum: Enum "NPR Retention Policy V2")
    var
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
    begin
        RetentionPolicyMgmt.UpsertTablePolicy(TableId, RetentionPolicyEnum);
    end;

    procedure DeleteTablePolicy(TableId: Integer)
    var
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
    begin
        RetentionPolicyMgmt.DeleteTablePolicy(TableId);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnDiscoverRetentionPolicyTables()
    begin
    end;

    [Obsolete('Use UpsertTablePolicyV2 with Enum "NPR Retention Policy V2" instead.', '2026-05-15')]
    procedure UpsertTablePolicy(TableId: Integer; var RetentionPolicyEnum: Enum "NPR Retention Policy")
    begin
        Error('NPR Retention Policy "UpsertTablePolicy" is obsolete. Use UpsertTablePolicyV2 with Enum "NPR Retention Policy V2" instead');
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeAddTableOnDiscoverRetentionPolicyTablesV2(TableId: Integer; var RetentionPolicy: Enum "NPR Retention Policy V2")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetRetentionPolicyPeriodsEditable(var Editable: Boolean)
    begin
    end;

    [Obsolete('Use OnBeforeAddTableOnDiscoverRetentionPolicyTablesV2 with Enum "NPR Retention Policy V2" instead.', '2026-05-15')]
    [IntegrationEvent(false, false)]
    procedure OnBeforeAddTableOnDiscoverRetentionPolicyTables(TableId: Integer; var RetentionPolicy: Enum "NPR Retention Policy")
    begin
    end;
}
#endif