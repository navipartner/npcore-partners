table 6059950 "NPR Display Setup"
{
    Caption = 'POS Display Profile';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
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


    procedure InitDisplayContent()
    var
        DisplayContent: Record "NPR Display Content";
    begin
        DisplayContent.Code := 'HTML';
        if not DisplayContent.Find() then begin
            DisplayContent.Init();
            DisplayContent.Type := DisplayContent.Type::Html;
            DisplayContent.Insert();
        end;

        DisplayContent.Code := 'IMAGE';
        if not DisplayContent.Find() then begin
            DisplayContent.Init();
            DisplayContent.Type := DisplayContent.Type::Image;
            DisplayContent.Insert();
        end;

        DisplayContent.Code := 'VIDEO';
        if not DisplayContent.Find() then begin
            DisplayContent.Init();
            DisplayContent.Type := DisplayContent.Type::Video;
            DisplayContent.Insert();
        end;

        OnAfterInitDisplayContent();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInitDisplayContent()
    begin
    end;
}

