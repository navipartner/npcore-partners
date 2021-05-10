codeunit 6014574 "NPR Lookup: BankDepositBinCode" implements "NPR IPOSLookupType"
{
    EventSubscriberInstance = StaticAutomatic;

    var
        LookupType: Enum "NPR POS Lookup Type";
        LookupTypeGeneration: Record "NPR POS Lookup Type Generation";

    #region IPOSLookupType implementation

    procedure InitializeDataRead(var RecRef: RecordRef);
    var
        Rec: Record "NPR POS Payment Bin";
    begin
        Rec.SetRange("Bin Type", Rec."Bin Type"::BANK);
        RecRef.GetTable(Rec);
    end;

    procedure GetLookupEntry(RecRef: RecordRef) Row: JsonObject;
    var
        Rec: Record "NPR POS Payment Bin";
    begin
        RecRef.SetTable(Rec);
        Row.Add('id', Rec."No.");
        Row.Add('storeId', Rec."POS Store Code");
        Row.Add('attachedToUnitId', Rec."Attached to POS Unit No.");
        Row.Add('description', Rec.Description);
    end;

    #endregion

    #region Event subscribers

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Payment Bin", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnPOSPaymentBinInsert(var Rec: Record "NPR POS Payment Bin")
    begin
        if Rec.IsTemporary() or (Rec."Bin Type" <> Rec."Bin Type"::BANK) then
            exit;

        LookupTypeGeneration.IncreaseGeneration(LookupType::BankDepositBinCode);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Payment Bin", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnPOSPaymentBinModify(var Rec: Record "NPR POS Payment Bin")
    begin
        if Rec.IsTemporary() or (Rec."Bin Type" <> Rec."Bin Type"::BANK) then
            exit;

        LookupTypeGeneration.IncreaseGeneration(LookupType::BankDepositBinCode);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Payment Bin", 'OnAfterRenameEvent', '', true, true)]
    local procedure OnPOSPaymentBinRename(var Rec: Record "NPR POS Payment Bin")
    begin
        if Rec.IsTemporary() or (Rec."Bin Type" <> Rec."Bin Type"::BANK) then
            exit;

        LookupTypeGeneration.IncreaseGeneration(LookupType::BankDepositBinCode);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Payment Bin", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnPOSPaymentBinDelete(var Rec: Record "NPR POS Payment Bin")
    begin
        if Rec.IsTemporary() or (Rec."Bin Type" <> Rec."Bin Type"::BANK) then
            exit;

        LookupTypeGeneration.IncreaseGeneration(LookupType::BankDepositBinCode);
    end;

    #endregion
}
