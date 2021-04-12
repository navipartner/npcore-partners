pageextension 6014402 "NPR Default Dimensions" extends "Default Dimensions"
{
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Table ID" <> DATABASE::"Item Category" then
            exit;

        ItemCategoryMgt.ApplyDimensionsToChildren(Rec, false, true);
    end;

    trigger OnModifyRecord(): Boolean
    var
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Table ID" <> DATABASE::"Item Category" then
            exit;

        if xRec."Dimension Value Code" = Rec."Dimension Value Code" then
            exit;

        ItemCategoryMgt.ApplyDimensionsToChildren(Rec, false, true);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Table ID" <> DATABASE::"Item Category" then
            exit;

        ItemCategoryMgt.ApplyDimensionsToChildren(Rec, true, true);
    end;
}