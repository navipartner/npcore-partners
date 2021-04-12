table 6060045 "NPR Registered Item Works."
{
    Caption = 'Item Worksheet Batch';
    DataClassification = CustomerContent;
    DataCaptionFields = "No.", "Worksheet Name", Description;
    LookupPageID = "NPR Registered Item Worksh.";

    fields
    {
        field(1; "No."; Integer)
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Worksheet Name"; Code[10])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;

            trigger OnValidate()
            begin
            end;
        }
        field(16; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Currency;
        }
        field(35; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
            end;
        }
        field(50; "Print Labels"; Boolean)
        {
            Caption = 'Print Labels';
            DataClassification = CustomerContent;
        }
        field(97; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(180; "Item Worksheet Template"; Code[10])
        {
            Caption = 'Item Worksheet Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Worksh. Template";
        }
        field(190; "Registered Date Time"; DateTime)
        {
            Caption = 'Registered Date Time';
            DataClassification = CustomerContent;
        }
        field(200; "Registered by User ID"; Code[50])
        {
            Caption = 'Registered by User ID';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
        }
        field(6014400; "Item Group"; Code[20])
        {
            Caption = 'Item Category';
            DataClassification = CustomerContent;
            TableRelation = "Item Category" WHERE("NPR Blocked" = CONST(false));
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    trigger OnDelete()
    begin
        RegisteredItemWorksheetLine.Reset();
        RegisteredItemWorksheetLine.SetRange("Registered Worksheet No.", "No.");
        RegisteredItemWorksheetLine.DeleteAll();

        RegItemWshtVariantLine.Reset();
        RegItemWshtVariantLine.SetRange("Registered Worksheet No.", "No.");
        RegItemWshtVariantLine.DeleteAll();

        RegItemWshtVarietyValue.Reset();
        RegItemWshtVarietyValue.SetRange("Registered Worksheet No.", "No.");
        RegItemWshtVarietyValue.DeleteAll();
    end;

    var
        RegisteredItemWorksheetLine: Record "NPR Regist. Item Worksh Line";
        RegItemWshtVariantLine: Record "NPR Reg. Item Wsht Var. Line";
        RegItemWshtVarietyValue: Record "NPR Reg. Item Wsht Var. Value";
}

