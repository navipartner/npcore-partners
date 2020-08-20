table 6151019 "NpRv Arch. Voucher Entry"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Renamed field 55 "Sales Ticket No." to "Document No." and added fields 53 "Document Type", 60 "External Document No."
    // NPR5.49/MHA /20190228  CASE 342811 Added partner fields
    // NPR5.50/MHA /20190426  CASE 353079 Added Option "Top Up" to field 10 "Entry Type"
    // NPR5.50/MMV /20190528  CASE 356712 Added field 85
    // NPR5.55/MHA /20200512  CASE 404116 Change Option [0] for field 53 "Document Type" from "Audit Roll" to "POS Entry"

    Caption = 'Archived Retail Voucher Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NpRv Arch. Voucher Entries";
    LookupPageID = "NpRv Arch. Voucher Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Arch. Voucher No."; Code[20])
        {
            Caption = 'Archived Voucher No.';
            DataClassification = CustomerContent;
            TableRelation = "NpRv Arch. Voucher";
        }
        field(10; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.49,NPR5.50';
            OptionCaption = ',Issue Voucher,Payment,Manual Archive,Partner Issue Voucher,Partner Payment,Top-up';
            OptionMembers = ,"Issue Voucher",Payment,"Manual Archive","Partner Issue Voucher","Partner Payment","Top-up";
        }
        field(15; "Voucher Type"; Code[20])
        {
            Caption = 'Voucher Type';
            DataClassification = CustomerContent;
            TableRelation = "NpRv Voucher Type";
        }
        field(17; Positive; Boolean)
        {
            Caption = 'Positive';
            DataClassification = CustomerContent;
        }
        field(20; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(25; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(30; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(40; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(50; "Register No."; Code[10])
        {
            Caption = 'Register No.';
            DataClassification = CustomerContent;
            TableRelation = Register."Register No.";
        }
        field(53; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.48,NPR5.55';
            OptionCaption = 'POS Entry,Invoice';
            OptionMembers = "POS Entry",Invoice;
        }
        field(55; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(60; "External Document No."; Code[50])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            Editable = false;
            NotBlank = true;
        }
        field(65; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(67; "Partner Code"; Code[20])
        {
            Caption = 'Partner Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
            TableRelation = "NpRv Partner";
        }
        field(70; "Closed by Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Closed by Entry No.';
            DataClassification = CustomerContent;
        }
        field(75; "Closed by Partner Code"; Code[20])
        {
            Caption = 'Closed by Partner Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
            TableRelation = "NpRv Partner";
        }
        field(80; "Partner Clearing"; Boolean)
        {
            Caption = 'Partner Clearing';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
        }
        field(85; "Original Entry No."; Integer)
        {
            Caption = 'Original Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Arch. Voucher No.")
        {
            SumIndexFields = Amount, "Remaining Amount";
        }
        key(Key3; "Entry Type", "Register No.", "Document No.")
        {
        }
    }

    fieldgroups
    {
    }
}

