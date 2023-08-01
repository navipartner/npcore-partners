table 6060001 "NPR Item Benefit List Header"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Item Benefit List Header';
    DrillDownPageId = "NPR Item Benefit Lists";
    LookupPageId = "NPR Item Benefit Lists";

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;

        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;

        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
    trigger OnModify()
    var
        NPRItemBenefListHeadUtils: Codeunit "NPR Item Benef List Head Utils";
    begin
        NPRItemBenefListHeadUtils.CheckIfListPartOfActiveTotalDiscount(Rec);
    end;

    trigger OnDelete()
    var
        NPRItemBenefListHeadUtils: Codeunit "NPR Item Benef List Head Utils";
    begin
        NPRItemBenefListHeadUtils.CheckIfListPartOfActiveTotalDiscount(Rec);
        NPRItemBenefListHeadUtils.DeleteLines(Rec);
    end;

    trigger OnRename()
    var
        NPRItemBenefListHeadUtils: Codeunit "NPR Item Benef List Head Utils";
    begin
        NPRItemBenefListHeadUtils.CheckIfListPartOfActiveTotalDiscount(xRec);
    end;

}