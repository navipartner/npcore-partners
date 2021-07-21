table 6014454 "NPR CleanCash Trans. VAT"
{
    DataClassification = CustomerContent;
    Caption = 'CleanCash Trans. VAT';

    fields
    {
        field(1; "Request Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Description = 'Register receipt serial number, a unique serial number for each receipt registered in a session. If the same serialnumber is sent repeatedly all but the first are ignored. (Max value 4294967295)';
        }

        field(2; "VAT Class"; Integer)
        {
            Caption = 'VAT Class';
            DataClassification = CustomerContent;
            Description = 'Digit describing the VAT class (1..4)';
            MinValue = 1;
            MaxValue = 4;
        }

        field(10; Percentage; Decimal)
        {
            Caption = 'Percentage';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
            Description = 'The percentage (e.g 25,00 for 25%).';
        }

        field(20; Amount; Decimal)
        {
            Caption = 'Net VAT Amount';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
            Description = 'The net VAT amount.';
        }

    }

    keys
    {
        key(PK; "Request Entry No.", "VAT Class")
        {
            Clustered = true;
        }
    }
}