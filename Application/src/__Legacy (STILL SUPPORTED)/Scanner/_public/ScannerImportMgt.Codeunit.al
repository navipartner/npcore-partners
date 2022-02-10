codeunit 6059780 "NPR Scanner Import Mgt."
{
    procedure GetItemNoFromScannedCode(ScannedCode: Text[50]): Code[20]
    var
        ItemNo: Code[20];
    begin
        if TryGetItemNoFromItem(ScannedCode, ItemNo) then
            exit(ItemNo);

        if TryGetItemNoFromItemReference(ScannedCode, ItemNo) then
            exit(ItemNo);

        Error(CannotFindItemErr, ScannedCode);
    end;

    local procedure TryGetItemNoFromItem(ScannedCode: Text[50]; var ItemNo: Code[20]): Boolean
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

    local procedure TryGetItemNoFromItemReference(ScannedCode: Text[50]; var ItemNo: Code[20]): Boolean
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
        exit(true);
    end;

    var
        CannotFindItemErr: Label 'Cannot find item with reference %1.', Comment = '%1 = Item Reference';
}