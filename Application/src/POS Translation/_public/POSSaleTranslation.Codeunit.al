codeunit 6014679 "NPR POS Sale Translation"
{
    procedure AssignLanguageCodeFromPOSAction(var POSSale: Record "NPR POS Sale"; LanguageCode: Code[10])
    begin
        POSSale."Language Code" := LanguageCode;
        AssignTranslationOnPOSSaleLines(POSSale);
    end;

    procedure AssignLanguageCodeFrom(var POSSale: Record "NPR POS Sale"; Rec: Variant)
    begin
        case true of
            (POSSale."Customer No." <> ''):
                AssignLanguageCodeFromCustomer(POSSale, Rec);
            (POSSale."Customer No." = ''):
                AssignLanguageCodeFromPOSStore(POSSale, Rec);
        end;
    end;

    local procedure AssignLanguageCodeFromCustomer(var POSSale: Record "NPR POS Sale"; Rec: Variant)
    var
        Customer: Record Customer;
    begin
        SetLanguageCode(POSSale, Rec, Customer.FieldName("Language Code"));
        AssignTranslationOnPOSSaleLines(POSSale);
    end;

    [Obsolete('Not Used.', '2023-06-28')]
    local procedure AssignLanguageCodeFromContact(var POSSale: Record "NPR POS Sale"; Rec: Variant)
    begin

    end;

    local procedure AssignLanguageCodeFromPOSStore(var POSSale: Record "NPR POS Sale"; Rec: Variant)
    var
        POSStore: Record "NPR POS Store";
    begin
        SetLanguageCode(POSSale, Rec, POSStore.FieldName("Language Code"));
        AssignTranslationOnPOSSaleLines(POSSale);
    end;

    local procedure SetLanguageCode(var POSSale: Record "NPR POS Sale"; Rec: Variant; AssignLanguageForFieldName: Text)
    var
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FieldReference: FieldRef;
    begin
        if not DataTypeMgt.GetRecordRef(Rec, RecRef) then
            exit;
        OnBeforeAssignLanguageCodeFrom(RecRef, AssignLanguageForFieldName);
        if not DataTypeMgt.FindFieldByName(RecRef, FieldReference, AssignLanguageForFieldName) then
            exit;
        POSSale."Language Code" := FieldReference.Value();
    end;

    local procedure AssignTranslationOnPOSSaleLines(POSSale: Record "NPR POS Sale")
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        if POSSale."Language Code" = '' then
            exit;
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);
        OnBeforeChangeTranslationPerPOSSaleLine(POSSaleLine, POSSale);
        if POSSaleLine.FindSet(true) then
            repeat
                AssignTranslationOnPOSSaleLine(POSSaleLine, POSSale);
                POSSaleLine.Modify();
            until POSSaleLine.Next() = 0;
    end;

    procedure AssignTranslationOnPOSSaleLine(var POSSaleLine: Record "NPR POS Sale Line"; POSSale: Record "NPR POS Sale")
    begin
        case POSSaleLine."Line Type" of
            POSSaleLine."Line Type"::Item:
                begin
                    GetItemTranslation(POSSaleLine, POSSale);
                end;
            else
                OnGetTranslation(POSSaleLine, POSSale);
        end;
    end;

    local procedure GetItemTranslation(var POSSaleLine: Record "NPR POS Sale Line"; POSSale: Record "NPR POS Sale")
    var
        ItemTranslation: Record "Item Translation";
    begin
        if ItemTranslation.Get(POSSaleLine."No.", POSSaleLine."Variant Code", POSSale."Language Code") then begin
            POSSaleLine.Description := CopyStr(ItemTranslation.Description, 1, MaxStrLen(POSSaleLine.Description));
            POSSaleLine."Description 2" := CopyStr(ItemTranslation."Description 2", 1, MaxStrLen(POSSaleLine."Description 2"));
            OnAfterGetItemTranslation(POSSaleLine, POSSale, ItemTranslation);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeChangeTranslationPerPOSSaleLine(var POSSaleLine: Record "NPR POS Sale Line"; POSSale: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetTranslation(var POSSaleLine: Record "NPR POS Sale Line"; POSSale: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetItemTranslation(var POSSaleLine: Record "NPR POS Sale Line"; POSSale: Record "NPR POS Sale"; ItemTranslation: Record "Item Translation")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssignLanguageCodeFrom(RecRef: RecordRef; var AssignLanguageForFieldName: Text)
    begin
    end;
}
