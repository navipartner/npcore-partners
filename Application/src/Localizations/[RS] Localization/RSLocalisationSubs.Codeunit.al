codeunit 6151390 "NPR RS Localisation Subs."
{
    Access = Internal;
    SingleInstance = true;

    var
        RSLocalisationMgt: Codeunit "NPR RS Localisation Mgt.";

    #region SyncRSVATEntryWithVATEntry

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInsertVATEntry', '', false, false)]
    local procedure GenJnlPostLine_OnAfterInsertVATEntry(GenJnlLine: Record "Gen. Journal Line"; VATEntry: Record "VAT Entry");
    var
        RSVATEntry: Record "NPR RS VAT Entry";
    begin
        if VATEntry.IsTemporary() then
            exit;
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        if not GenJnlLine.Prepayment then
            exit;
        if not RSVATEntry.Get(VATEntry."Entry No.") then
            exit;
        RSVATEntry.Prepayment := GenJnlLine.Prepayment;
        RSVATEntry.Modify();
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertVATEntry(var Rec: Record "VAT Entry")
    var
        RSVATEntry: Record "NPR RS VAT Entry";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        RSVATEntry.TransferFields(Rec);
        RSVATEntry.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyVATEntry(var Rec: Record "VAT Entry")
    var
        RSVATEntry: Record "NPR RS VAT Entry";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        if not RSVATEntry.Get(Rec."Entry No.") then
            exit;
        RSVATEntry.TransferFields(Rec);
        RSVATEntry.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteVATEntry(var Rec: Record "VAT Entry")
    var
        RSVATEntry: Record "NPR RS VAT Entry";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        if not RSVATEntry.Get(Rec."Entry No.") then
            exit;
        RSVATEntry.Delete(true);
    end;
    #endregion
}