codeunit 6184844 "NPR SE CC Cash Reg. Audit Mgt."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', false, false)]
    local procedure InsertAuditLog_OnAfterDeleteItem(var Rec: Record Item)
    var
        SECCCashRegAuditLog: Record "NPR SE CC Cash Reg. Audit Log";
        VATPostingSetup: Record "VAT Posting Setup";
        AuditLogDesc, AdditionalInfo : Text;
        VATPercentage: Decimal;
        AuditLogDescLbl: Label 'Item: %1 Deleted.', Comment = '%1 - specifies Item No.';
        AdditionalInfoLbl: Label '%1:%2:%3:%4:%5:%6:%7:%8', Locked = true, Comment = '%1 - Item No., %2 - Item Description, %3 - Inventory, %4 - Unit of Measure, %5 - Unit Price, %6 - Price Incl. VAT, %7 - VAT %, %8 - Creation Time';
    begin
        if not IsSECleanCashEnabled() then
            exit;

        Clear(VATPercentage);
        if VATPostingSetup.Get(Rec."VAT Bus. Posting Gr. (Price)", Rec."VAT Prod. Posting Group") then
            VATPercentage := VATPostingSetup."VAT %";

        AuditLogDesc := StrSubstNo(AuditLogDescLbl, Rec."No.");
        AdditionalInfo := StrSubstNo(AdditionalInfoLbl, Rec."No.", Rec.Description, Rec.Inventory, Rec."Base Unit of Measure", Rec."Unit Price", Rec."Price Includes VAT", VATPercentage, Rec.SystemCreatedAt);

        CreateAuditLogEntry(Rec.RecordId, SECCCashRegAuditLog."Entry Type"::DELETE_ITEM, AuditLogDesc, AdditionalInfo);
    end;

    #region SE CleanCash Audit Entry Initialization 

    procedure CreateAuditLogEntry(RecordIdIn: RecordId; EntryType: Enum "NPR SE CC Audit Entry Type"; Description: Text; AddInfo: Text)
    var
        SECCCashRegAuditLog: Record "NPR SE CC Cash Reg. Audit Log";
    begin
        SECCCashRegAuditLog.Init();
        SECCCashRegAuditLog."Record ID" := RecordIdIn;
        SECCCashRegAuditLog."Entry Type" := EntryType;
        SECCCashRegAuditLog."External Description" := CopyStr(Description, 1, MaxStrLen(SECCCashRegAuditLog."External Description"));
        SECCCashRegAuditLog."Additional Information" := CopyStr(AddInfo, 1, MaxStrLen(SECCCashRegAuditLog."Additional Information"));
        SECCCashRegAuditLog."Entry Date" := WorkDate();

        if Format(RecordIDIn) <> '' then
            SECCCashRegAuditLog."Table ID" := RecordIdIn.TableNo();

        SECCCashRegAuditLog.Insert(true);
    end;

    #endregion SE CleanCash Audit Entry Initialization

    #region SE CleanCash Helper Procedures

    local procedure IsSECleanCashEnabled(): Boolean
    var
        SEFiscalizationSetup: Record "NPR SE Fiscalization Setup.";
    begin
        if not SEFiscalizationSetup.Get() then
            exit(false);

        exit(SEFiscalizationSetup."Enable SE Fiscal");
    end;

    #endregion
}