table 6060045 "Registered Item Worksheet"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created

    Caption = 'Item Worksheet Batch';
    DataClassification = CustomerContent;
    DataCaptionFields = "No.", "Worksheet Name", Description;
    LookupPageID = "Registered Item Worksheets";

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
            var
                Vend: Record Vendor;
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
            var
                PurchLine: Record "Purchase Line";
                Currency: Record Currency;
                RecalculatePrice: Boolean;
            begin
            end;
        }
        field(50; "Print Labels"; Boolean)
        {
            Caption = 'Print Labels';
            DataClassification = CustomerContent;
        }
        field(97; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(180; "Item Worksheet Template"; Code[10])
        {
            Caption = 'Item Worksheet Template';
            DataClassification = CustomerContent;
            TableRelation = "Item Worksheet Template";
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
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(6014400; "Item Group"; Code[10])
        {
            Caption = 'Item Group';
            DataClassification = CustomerContent;
            TableRelation = "Item Group" WHERE(Blocked = CONST(false));

            trigger OnValidate()
            var
                ItemGroup: Record "Item Group";
            begin
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        RegisteredItemWorksheetLine.Reset;
        RegisteredItemWorksheetLine.SetRange("Registered Worksheet No.", "No.");
        RegisteredItemWorksheetLine.DeleteAll;

        RegItemWshtVariantLine.Reset;
        RegItemWshtVariantLine.SetRange("Registered Worksheet No.", "No.");
        RegItemWshtVariantLine.DeleteAll;

        RegItemWshtVarietyValue.Reset;
        RegItemWshtVarietyValue.SetRange("Registered Worksheet No.", "No.");
        RegItemWshtVarietyValue.DeleteAll;
    end;

    var
        RegisteredItemWorksheetLine: Record "Registered Item Worksheet Line";
        RegItemWshtVariantLine: Record "Reg. Item Wsht Variant Line";
        RegItemWshtVarietyValue: Record "Reg. Item Wsht Variety Value";
}

