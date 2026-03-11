table 6151267 "NPR NpIa Item AddOn Category"
{
    Access = Internal;
    Extensible = false;
    Caption = 'Item AddOn Category';
    DataClassification = CustomerContent;
    LookupPageID = "NPR NpIa Item AddOn Categories";
    DrillDownPageID = "NPR NpIa Item AddOn Categories";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Sort Key"; Integer)
        {
            Caption = 'Sort Key';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Sort Key")
        {
        }
    }

    trigger OnInsert()
    var
        NpIaItemAddOnCategory: Record "NPR NpIa Item AddOn Category";
    begin
        NpIaItemAddOnCategory.SetCurrentKey("Sort Key");
        NpIaItemAddOnCategory.Ascending(true);
        NpIaItemAddOnCategory.SetFilter("Code", '<>%1', Rec."Code");
        if NpIaItemAddOnCategory.FindLast() then
            Rec."Sort Key" := NpIaItemAddOnCategory."Sort Key" + 10000
        else
            Rec."Sort Key" := 10000;
    end;

    trigger OnDelete()
    var
        ItemAddOnCategoryTrans: Record "NPR NpIa ItemAddOn Cat. Trans.";
    begin
        ItemAddOnCategoryTrans.SetRange("Category Code", Code);
        ItemAddOnCategoryTrans.DeleteAll(true);
    end;
}
