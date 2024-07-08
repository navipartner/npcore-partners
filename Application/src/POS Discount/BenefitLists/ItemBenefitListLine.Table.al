table 6060002 "NPR Item Benefit List Line"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Item Benefit List Line';

    fields
    {
        field(1; "List Code"; Code[20])
        {
            Caption = 'List Code';
            DataClassification = CustomerContent;

        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;

        }
        field(20; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = Item WHERE(Blocked = CONST(false), "Sales Blocked" = CONST(false));
            trigger OnValidate()
            var
                NPRItemBenefListLineUtils: Codeunit "NPR Item Benef List Line Utils";
            begin
                if Rec."No." <> xRec."No." then begin
                    NPRItemBenefListLineUtils.UpdateItemFields(Rec);
                    Rec."Variant Code" := '';
                end;
            end;
        }
        field(30; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRItemBenefListLineUtils: Codeunit "NPR Item Benef List Line Utils";
            begin
                if Rec."Variant Code" <> xRec."Variant Code" then
                    NPRItemBenefListLineUtils.UpdateItemFields(Rec);
            end;
        }

        field(40; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(50; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            BlankZero = true;
        }

        field(60; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            BlankZero = true;
        }
    }


    keys
    {
        key(Key1; "List Code", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        NPRItemBenefListLineUtils: Codeunit "NPR Item Benef List Line Utils";
    begin
        NPRItemBenefListLineUtils.CheckIfListPartOfActiveTotalDiscount(Rec);
    end;

    trigger OnModify()
    var
        NPRItemBenefListLineUtils: Codeunit "NPR Item Benef List Line Utils";
    begin
        NPRItemBenefListLineUtils.CheckIfListPartOfActiveTotalDiscount(Rec);
    end;

    trigger OnDelete()
    var
        NPRItemBenefListLineUtils: Codeunit "NPR Item Benef List Line Utils";
    begin
        NPRItemBenefListLineUtils.CheckIfListPartOfActiveTotalDiscount(Rec);
    end;

    trigger OnRename()
    var
        NPRItemBenefListLineUtils: Codeunit "NPR Item Benef List Line Utils";
    begin
        NPRItemBenefListLineUtils.CheckIfListPartOfActiveTotalDiscount(xRec);
    end;

}