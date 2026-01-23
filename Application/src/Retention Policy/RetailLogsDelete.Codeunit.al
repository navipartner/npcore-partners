#if (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6059926 "NPR Retail Logs Delete"
{
    // based on codeunit 3913 "Retention Policy Logs Delete" from Base App
    Access = Internal;
    Permissions =
        tabledata "NPR Data Log Record" = rd,
        tabledata "NPR Data Log Field" = rd,
        tabledata "NPR Tax Free Voucher" = rd,
        tabledata "NPR POS Saved Sale Entry" = rd,
        tabledata "NPR POS Saved Sale Line" = rd,
        tabledata "NPR NpCs Arch. Document" = rd,
        tabledata "NPR Nc Task" = rd,
        tabledata "NPR Exchange Label" = rd,
        tabledata "NPR NpGp POS Sales Entry" = rd,
        tabledata "NPR POS Entry Output Log" = rd,
        tabledata "NPR Nc Import Entry" = rd,
        tabledata "NPR POS Period Register" = rd,
        tabledata "NPR POS Entry" = rd,
        tabledata "NPR POS Entry Sales Line" = rd,
        tabledata "NPR POS Entry Payment Line" = rd,
        tabledata "NPR POS Balancing Line" = rd,
        tabledata "NPR POS Entry Tax Line" = rd,
        tabledata "NPR POS Posting Log" = rd,
        tabledata "NPR EFT Transaction Request" = rd,
        tabledata "NPR Replication Error Log" = rd,
        tabledata "NPR BTF EndPoint Error Log" = rd,
        tabledata "NPR MM Admis. Service Entry" = rd,
        tabledata "NPR EFT Receipt" = rd,
        tabledata "NPR POS Layout Archive" = rd,
        tabledata "NPR M2 Record Change Log" = rd,
        tabledata "NPR Sales Price Maint. Log" = rd;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Apply Retention Policy", 'OnApplyRetentionPolicyIndirectPermissionRequired', '', true, true)]
    local procedure DeleteRecordsWithIndirectPermissionsOnApplyRetentionPolicyIndirectPermissionRequired(var RecRef: RecordRef; var Handled: Boolean)
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
#IF NOT BC17 AND NOT BC18
        RetenPolDataArchive: Codeunit "NPR Reten. Pol. Data Archive";
#ENDIF
        NoFiltersErr: Label 'No filters were set on table %1, %2. Please contact your Microsoft Partner for assistance.', Comment = '%1 = a id of a table (integer), %2 = the caption of the table.';
    begin
        // if someone else took it, exit
        if Handled then
            exit;

        // check if we can handle the table
        // if you add a new table here, also update this CU permissions
        if not (RecRef.Number in [
            Database::"NPR Data Log Record",
            Database::"NPR Data Log Field",
            Database::"NPR Tax Free Voucher",
            Database::"NPR POS Saved Sale Entry",
            Database::"NPR POS Saved Sale Line",
            Database::"NPR NpCs Arch. Document",
            Database::"NPR Nc Task",
            Database::"NPR Exchange Label",
            Database::"NPR NpGp POS Sales Entry",
            Database::"NPR POS Entry Output Log",
            Database::"NPR Nc Import Entry",
            Database::"NPR POS Period Register",
            Database::"NPR POS Entry",
            Database::"NPR POS Entry Sales Line",
            Database::"NPR POS Entry Payment Line",
            Database::"NPR POS Balancing Line",
            Database::"NPR POS Entry Tax Line",
            Database::"NPR POS Posting Log",
            Database::"NPR EFT Transaction Request",
            Database::"NPR Replication Error Log",
            Database::"NPR BTF EndPoint Error Log",
            Database::"NPR MM Admis. Service Entry",
            Database::"NPR EFT Receipt",
            Database::"NPR POS Layout Archive",
            Database::"NPR M2 Record Change Log",
            Database::"NPR Sales Price Maint. Log"])
        then
            exit;

        // if no filters have been set, something is wrong.
        if (RecRef.GetFilters() = '') or (not RecRef.MarkedOnly()) then
            RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(NoFiltersErr, RecRef.Number, RecRef.Name));

#IF NOT BC17 AND NOT BC18
        RetenPolDataArchive.CreateDataArchive(RecRef);
#ENDIF

        // delete all remaining records
        RecRef.DeleteAll();

#IF NOT BC17 AND NOT BC18
        RetenPolDataArchive.SaveDataArchive();
#ENDIF

        // set handled
        Handled := true;
    end;

    local procedure LogCategory(): Enum "Retention Policy Log Category"
    var
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
    begin
        exit(RetentionPolicyLogCategory::"Retention Policy - Apply");
    end;
}
#endif