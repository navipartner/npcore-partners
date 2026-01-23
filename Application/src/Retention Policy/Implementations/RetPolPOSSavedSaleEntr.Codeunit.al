#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248718 "NPR Ret.Pol.: POSSavedSaleEntr" implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-3M>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        POSSavedSaleEntry.SetRange("Contains EFT Approval", false);
        POSSavedSaleEntry.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not POSSavedSaleEntry.IsEmpty() then begin
            POSSavedSaleEntry.SkipLineDeleteTrigger(true);
            POSSavedSaleEntry.DeleteAll(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRPOSSavedSaleEntryOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR POS Saved Sale Entry";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR POS Saved Sale Entry", RetentionPolicyImpl);
        RetentionPolicyMgmt.AddTablePolicy(Database::"NPR POS Saved Sale Entry", RetentionPolicyImpl);
    end;
}
#endif