tableextension 6014439 "NPR Config. Template Line" extends "Config. Template Line"
{
    trigger OnAfterModify()
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
        ItemDiscGroupCode: Code[20];
        xItemDiscGroupCode: Code[20];
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Data Template Code" = '' then
            exit;

        if Rec."Default Value" = xRec."Default Value" then
            exit;

        if (Rec."Table ID" = Database::Item) and (Rec."Field ID" = Item.FieldNo("Item Disc. Group")) then begin
            ItemCategory.SetRange("NPR Item Template Code", Rec."Data Template Code");
            if ItemCategory.FindSet() then begin
                Evaluate(ItemDiscGroupCode, Rec."Default Value");
                Evaluate(xItemDiscGroupCode, xRec."Default Value");

                repeat
                    ItemCategoryMgt.UpdateItemDiscGroupOnItems(ItemCategory, ItemDiscGroupCode, xItemDiscGroupCode);
                until ItemCategory.Next() = 0;
            end;
        end;
    end;
}