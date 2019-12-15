table 6060045 "Registered Item Worksheet"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created

    Caption = 'Item Worksheet Batch';
    DataCaptionFields = "No.","Worksheet Name",Description;
    LookupPageID = "Registered Item Worksheets";

    fields
    {
        field(1;"No.";Integer)
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2;"Worksheet Name";Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(3;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate()
            var
                Vend: Record Vendor;
            begin
            end;
        }
        field(16;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(35;"Prices Including VAT";Boolean)
        {
            Caption = 'Prices Including VAT';

            trigger OnValidate()
            var
                PurchLine: Record "Purchase Line";
                Currency: Record Currency;
                RecalculatePrice: Boolean;
            begin
            end;
        }
        field(50;"Print Labels";Boolean)
        {
            Caption = 'Print Labels';
        }
        field(97;"No. Series";Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(180;"Item Worksheet Template";Code[10])
        {
            Caption = 'Item Worksheet Template';
            TableRelation = "Item Worksheet Template";
        }
        field(190;"Registered Date Time";DateTime)
        {
            Caption = 'Registered Date Time';
        }
        field(200;"Registered by User ID";Code[50])
        {
            Caption = 'Registered by User ID';
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(6014400;"Item Group";Code[10])
        {
            Caption = 'Item Group';
            TableRelation = "Item Group" WHERE (Blocked=CONST(false));

            trigger OnValidate()
            var
                ItemGroup: Record "Item Group";
            begin
            end;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        RegisteredItemWorksheetLine.Reset;
        RegisteredItemWorksheetLine.SetRange("Registered Worksheet No.","No.");
        RegisteredItemWorksheetLine.DeleteAll;

        RegItemWshtVariantLine.Reset;
        RegItemWshtVariantLine.SetRange("Registered Worksheet No.","No.");
        RegItemWshtVariantLine.DeleteAll;

        RegItemWshtVarietyValue.Reset;
        RegItemWshtVarietyValue.SetRange("Registered Worksheet No.","No.");
        RegItemWshtVarietyValue.DeleteAll;
    end;

    var
        RegisteredItemWorksheetLine: Record "Registered Item Worksheet Line";
        RegItemWshtVariantLine: Record "Reg. Item Wsht Variant Line";
        RegItemWshtVarietyValue: Record "Reg. Item Wsht Variety Value";
}

