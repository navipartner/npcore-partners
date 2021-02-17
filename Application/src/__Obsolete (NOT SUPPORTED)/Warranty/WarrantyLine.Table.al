table 6014519 "NPR Warranty Line"
{
    Caption = 'Warranty Line';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Warranty No."; Code[20])
        {
            Caption = 'Warranty No.';
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
            DataClassification = CustomerContent;
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
        }
        field(11; "Policy 2"; Boolean)
        {
            Caption = 'Policy 2';
            DataClassification = CustomerContent;
        }
        field(12; "Policy 3"; Boolean)
        {
            Caption = 'Policy 3';
            DataClassification = CustomerContent;
        }
        field(13; InsuranceType; Code[50])
        {
            Caption = 'Insurance Type ';
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
    }

    fieldgroups
    {
    }
}

