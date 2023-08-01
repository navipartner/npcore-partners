table 6059875 "NPR Total Discount Line"
{
    Access = Internal;
    Caption = 'Total Discount Line';
    DataClassification = CustomerContent;
    LookupPageId = "NPR Total Discount Lines";
    DrillDownPageId = "NPR Total Discount Lines";
    fields
    {
        field(1; "Total Discount Code"; Code[20])
        {
            Caption = 'Total Discount Code';
            TableRelation = "NPR Total Discount Header".Code;
            DataClassification = CustomerContent;
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if ("Type" = CONST(Item)) Item
            else
            if ("Type" = CONST("Item Category")) "Item Category"
            else
            if ("Type" = CONST("Vendor")) "Vendor";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotalDiscLineUtils: Codeunit "NPR Total Disc. Line Utils";
            begin
                NPRTotalDiscLineUtils.UpdateLineNoInformation(Rec);
            end;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; Status; Enum "NPR Total Discount Status")
        {
            Caption = 'Status';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("No.");
            end;
        }
        field(7; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(8; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(9; Type; Enum "NPR Total Discount Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                NPRTotalDiscLineUtils: Codeunit "NPR Total Disc. Line Utils";
            begin
                if Rec.Type <> xRec.Type then
                    NPRTotalDiscLineUtils.ClearTypeRelatedFields(Rec);
            end;
        }
        field(10; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
            DataClassification = CustomerContent;
        }

        field(11; "Vendor Item No."; Text[50])
        {
            Caption = 'Vendor Item No.';
            DataClassification = CustomerContent;
        }
        field(12; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(13; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(302; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Total Discount Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Total Discount Code", "Type", "No.", "Variant Code")
        {
        }
        key(Key3; "No.")
        {
        }
        key(Key4; "Last Date Modified")
        {
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(key5; SystemRowVersion)
        {
        }
#ENDIF
    }

    trigger OnDelete()
    var
        NPRTotalDiscLineUtils: Codeunit "NPR Total Disc. Line Utils";
    begin
        NPRTotalDiscLineUtils.UpdateHaderModifyInformation(Rec);
        NPRTotalDiscLineUtils.CheckIfTotalDiscountEditable(Rec);
    end;

    trigger OnInsert()
    var
        NPRTotalDiscLineUtils: Codeunit "NPR Total Disc. Line Utils";
    begin
        NPRTotalDiscLineUtils.UpdateHaderModifyInformation(Rec);
        NPRTotalDiscLineUtils.UpdateLineWithHeaderInformation(Rec);
        NPRTotalDiscLineUtils.CheckIfTotalDiscountEditable(Rec);
    end;

    trigger OnModify()
    var
        NPRTotalDiscLineUtils: Codeunit "NPR Total Disc. Line Utils";
    begin
        Rec."Last Date Modified" := Today();
        NPRTotalDiscLineUtils.UpdateHaderModifyInformation(Rec);
        NPRTotalDiscLineUtils.UpdateLineWithHeaderInformation(Rec);
        NPRTotalDiscLineUtils.CheckIfTotalDiscountEditable(Rec);
    end;

    trigger OnRename()
    var
        NPRTotalDiscLineUtils: Codeunit "NPR Total Disc. Line Utils";
    begin
        NPRTotalDiscLineUtils.UpdateHaderModifyInformation(Rec);
        NPRTotalDiscLineUtils.UpdateLineWithHeaderInformation(Rec);
        NPRTotalDiscLineUtils.CheckIfTotalDiscountEditable(Rec);
    end;
}

