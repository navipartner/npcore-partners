codeunit 6059933 "NPR Rep. Timestamp Upgrade"
{
    Access = Internal;
    // run only for BC21 or newer
#IF NOT (BC17 or BC18 or BC19 or BC20)
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeRepCounterToSQLTimestamp();
    end;

    local procedure UpgradeRepCounterToSQLTimestamp()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Replication Timestamp Upgrade.', 'UpgradeReplicationTimestamp');

        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Rep. Timestamp Upgrade")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeReplicationEndpoints();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Rep. Timestamp Upgrade"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeReplicationEndpoints()
    var
        RepEndpoint: Record "NPR Replication Endpoint";
        ReplicationSetup: Record "NPR Replication Service Setup";
    begin
        if RepEndpoint.FindSet(true) then
            Repeat
#pragma warning disable AA0139
                RepEndpoint.Path := RepEndpoint.Path.Replace('replicationCounter', 'systemRowVersion');
                case RepEndpoint."Table ID" of
                    Database::"G/L Account":
                        RepEndpoint.Path := RepEndpoint.Path.Replace('glAccountsRead', 'glAccounts');
                    Database::"NPR Aux. G/L Account":
                        RepEndpoint.Path := RepEndpoint.Path.Replace('glAccountsRead', 'auxGLAccounts');
                end;
#pragma warning restore
                if ReplicationSetup."API Version" <> RepEndpoint."Service Code" then
                    if ReplicationSetup.Get(RepEndpoint."Service Code") then;
                UpgradeReplicationCounter(RepEndpoint, ReplicationSetup);
                RepEndpoint.Modify();
            Until RepEndpoint.Next() = 0;
    end;

    local procedure UpgradeReplicationCounter(var RepEndpoint: Record "NPR Replication Endpoint"; ReplicationSetup: Record "NPR Replication Service Setup")
    var
        RecRef: RecordRef;
        FRef: FieldRef;
        FRefTimestamp: FieldRef;
        DataTypeMgmt: Codeunit "Data Type Management";
    begin
        if RepEndpoint."Replication Counter" > 0 then
            if (not ReplicationSetup."External Database") and (ReplicationSetup.FromCompany <> '') then begin
                RecRef.Open(RepEndpoint."Table ID"); //open RecordRef using table id.
                if RecRef.ChangeCompany(ReplicationSetup.FromCompany) then begin
                    if not DataTypeMgmt.FindFieldByName(RecRef, FRef, 'NPR Replication Counter') then
                        if not DataTypeMgmt.FindFieldByName(RecRef, FRef, 'Replication Counter') then
                            exit;

                    FRef.SetRange(RepEndpoint."Replication Counter");
                    if RecRef.FindFirst() then begin
                        if not DataTypeMgmt.FindFieldByName(RecRef, FRefTimestamp, 'timestamp') then
                            exit;

                        RepEndpoint."Replication Counter" := FRefTimestamp.Value; // set the value of the SQL Timestamp
                    end;
                end;
            end;
    end;
#ENDIF
}
