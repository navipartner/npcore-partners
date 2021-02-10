table 6059950 "NPR Display Setup"
{
    // NPR5.29/CLVA/20170118 CASE 256153 Added field "Image Rotation Interval"
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.43/CLVA/20180606 CASE 300254 Added field Activate
    // NPR5.44/CLVA/20180629 CASE 318695 Added field Prices ex. VAT
    // NPR5.50/CLVA/20190513 CASE 352390 Added field "Custom Display Codeunit"
    // NPR5.51/ANPA/20190722 CASE 352390 Added field "Hide reciept"

    Caption = 'Display Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register";
        }
        field(11; "Display Content Code"; Code[10])
        {
            Caption = 'Display Content Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Display Content";

            trigger OnValidate()
            begin
                if ("Display Content Code" <> xRec."Display Content Code") and ("Display Content Code" <> '') then
                    "Media Downloaded" := false;
            end;
        }
        field(12; "Screen No."; Integer)
        {
            Caption = 'Screen No.';
            DataClassification = CustomerContent;
        }
        field(13; "Receipt Duration"; Integer)
        {
            Caption = 'Receipt Duration';
            DataClassification = CustomerContent;
            Description = 'Milliseconds';
            InitValue = 5000;
        }
        field(14; "Receipt Width Pct."; Integer)
        {
            Caption = 'Receipt Width Pct.';
            DataClassification = CustomerContent;
            InitValue = 50;
        }
        field(15; "Receipt Placement"; Option)
        {
            Caption = 'Receipt Placement';
            DataClassification = CustomerContent;
            InitValue = Right;
            OptionCaption = 'Left,Center,Right';
            OptionMembers = Left,Center,Right;
        }
        field(16; "Media Downloaded"; Boolean)
        {
            Caption = 'Media Downloaded';
            DataClassification = CustomerContent;
        }
        field(17; "Receipt Description Padding"; Integer)
        {
            Caption = 'Receipt Description Padding';
            DataClassification = CustomerContent;
            InitValue = 15;
        }
        field(18; "Receipt Total Padding"; Integer)
        {
            Caption = 'Receipt Total Padding';
            DataClassification = CustomerContent;
            InitValue = 20;
        }
        field(19; "Receipt GrandTotal Padding"; Integer)
        {
            Caption = 'Receipt GrandTotal Padding';
            DataClassification = CustomerContent;
            InitValue = 36;
        }
        field(20; "Receipt Discount Padding"; Integer)
        {
            Caption = 'Receipt Discount Padding';
            DataClassification = CustomerContent;
            InitValue = 20;
        }
        field(21; "Image Rotation Interval"; Integer)
        {
            Caption = 'Image Rotation Interval';
            DataClassification = CustomerContent;
            Description = 'Milliseconds';
            InitValue = 3000;
        }
        field(22; Activate; Boolean)
        {
            Caption = 'Activate';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Register: Record "NPR Register";
            begin
                if (xRec.Activate) and (not Activate) then
                    "Media Downloaded" := false;
            end;
        }
        field(23; "Prices ex. VAT"; Boolean)
        {
            Caption = 'Prices ex. VAT';
            DataClassification = CustomerContent;
        }
        field(24; "Custom Display Codeunit"; Integer)
        {
            Caption = 'Custom Display Codeunit';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(25; "Hide receipt"; Boolean)
        {
            Caption = 'Hide receipt';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
        }
    }

    keys
    {
        key(Key1; "Register No.")
        {
        }
    }

    fieldgroups
    {
    }
}

