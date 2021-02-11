table 6014519 "NPR Warranty Line"
{
    // //-NPR3.0g
    //   Tilf¢jet insurance
    // NPR5.38/TJ  /20171218  CASE 225415 Renumbered fields from range 50xxx to range below 50000

    Caption = 'Warranty Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Warranty No."; Code[20])
        {
            Caption = 'Warranty No.';
            TableRelation = "NPR Warranty Directory";
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Vare: Record Item;
            begin
                Vare.Get("Item No.");
                Description := Vare.Description;
                if Vare."NPR Insurrance category" <> '' then
                    Validate(InsuranceType, Vare."NPR Insurrance category");
            end;
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(5; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(6; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(7; "Amount incl. VAT"; Decimal)
        {
            Caption = 'Amount incl. VAT';
            DataClassification = CustomerContent;
        }
        field(8; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;
        }
        field(9; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Policy 1"; Boolean)
        {
            Caption = 'Policy 1';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Policy 1" then begin
                    "Policy 2" := false;
                    "Policy 3" := false;
                end;
            end;
        }
        field(11; "Policy 2"; Boolean)
        {
            Caption = 'Policy 2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Policy 2" then begin
                    "Policy 1" := false;
                    "Policy 3" := false;
                end;
            end;
        }
        field(12; "Policy 3"; Boolean)
        {
            Caption = 'Policy 3';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Policy 3" then begin
                    "Policy 1" := false;
                    "Policy 2" := false;
                end;
            end;
        }
        field(13; InsuranceType; Code[50])
        {
            Caption = 'Insurance Type ';
            TableRelation = "NPR Insurance Category";
            DataClassification = CustomerContent;
        }
        field(14; Insurance; Boolean)
        {
            Caption = 'Insurance';
            DataClassification = CustomerContent;
        }
        field(15; "Serial No. not Created"; Code[50])
        {
            Caption = 'Serial No. not Created';
            DataClassification = CustomerContent;
        }
        field(20; "Lock Code"; Code[10])
        {
            Caption = 'Lock Code';
            DataClassification = CustomerContent;
        }
        field(43; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
        field(129; "Insurance send"; Date)
        {
            Caption = 'Insurance send';
            DataClassification = CustomerContent;
        }
        field(6014511; "Label No."; Code[8])
        {
            Caption = 'Label Number';
            Description = 'Benyttes i forbindelse med Smart Safety forsikring';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Warranty No.", "Line No.")
        {
            SumIndexFields = "Amount incl. VAT";
        }
        key(Key2; "Warranty No.", "Policy 1", "Policy 2", "Policy 3", InsuranceType)
        {
            SumIndexFields = "Amount incl. VAT";
        }
        key(Key3; InsuranceType)
        {
        }
    }

    fieldgroups
    {
    }
}

