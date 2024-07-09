codeunit 6059780 "NPR Scanner Import Mgt."
{
    Access = Public;

    procedure GetItemNoFromScannedCode(ScannedCode: Text): Code[20]
    var
        CannotFindItemErr: Label 'Cannot find item with reference %1.', Comment = '%1 = Item Reference';
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        if TryGetItemNoFromItem(ScannedCode, ItemNo) then
            exit(ItemNo);

        if TryGetItemNoFromItemReference(ScannedCode, ItemNo, VariantCode) then
            exit(ItemNo);

        Error(CannotFindItemErr, ScannedCode);
    end;

    [Obsolete('Use procedure GetItemAndVariantCodeFromScannedCode instead', '2023-06-28')]
    procedure GetItemNoAndVariantCodeFromScannedCode(ScannedCode: Text[50]; var ItemNo: Code[20]; var VariantCode: Code[20])
    var
        CannotFindItemErr: Label 'Cannot find item with reference %1.', Comment = '%1 = Item Reference';
    begin
        ItemNo := '';
        VariantCode := '';

        if TryGetItemNoFromItem(ScannedCode, ItemNo) then
            exit;

# pragma warning disable AA0139 
        if TryGetItemNoFromItemReference(ScannedCode, ItemNo, VariantCode) then
# pragma warning restore
            exit;

        Error(CannotFindItemErr, ScannedCode);
    end;

    procedure GetItemAndVariantCodeFromScannedCode(ScannedCode: Text; var ItemNo: Code[20]; var VariantCode: Code[10])
    var
        CannotFindItemErr: Label 'Cannot find item with reference %1.', Comment = '%1 = Item Reference';
    begin
        ItemNo := '';
        VariantCode := '';

        if TryGetItemNoFromItem(ScannedCode, ItemNo) then
            exit;

        if TryGetItemNoFromItemReference(ScannedCode, ItemNo, VariantCode) then
            exit;

        Error(CannotFindItemErr, ScannedCode);
    end;

    local procedure TryGetItemNoFromItem(ScannedCode: Text; var ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if StrLen(ScannedCode) > MaxStrLen(Item."No.") then
            exit(false);

        if not Item.Get(ScannedCode) then
            exit(false);

        ItemNo := Item."No.";
        exit(true);
    end;

    local procedure TryGetItemNoFromItemReference(ScannedCode: Text; var ItemNo: Code[20]; var VariantCode: Code[10]): Boolean
    var
        ItemReference: Record "Item Reference";
    begin
        if StrLen(ScannedCode) > MaxStrLen(ItemReference."Reference No.") then
            exit(false);

        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference No.", ScannedCode);
        if not ItemReference.FindFirst() then
            exit(false);

        ItemNo := ItemReference."Item No.";
        VariantCode := ItemReference."Variant Code";
        exit(true);
    end;

    procedure CreateErrorMessage(var TempErrorMessage: Record "Error Message" temporary)
    begin
        TempErrorMessage.ID += 1;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC2100 or BC2101 or BC2102 or BC2103)
        TempErrorMessage.Message := CopyStr(GetLastErrorText(), 1, MaxStrLen(TempErrorMessage.Message));
#ELSE
        TempErrorMessage.Description := CopyStr(GetLastErrorText(), 1, MaxStrLen(TempErrorMessage.Description));
#ENDIF 
        TempErrorMessage.Insert();
    end;

    procedure ImportFromScanner(IScannerProvider: Interface "NPR IScanner Provider"; ScannerImport: Enum "NPR Scanner Import"; RecRef: RecordRef)
    begin
        IScannerProvider.Import(ScannerImport, RecRef);
    end;
}
