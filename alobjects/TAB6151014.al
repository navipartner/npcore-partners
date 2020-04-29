table 6151014 "NpRv Voucher Entry"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Renamed field 55 "Sales Ticket No." to "Document No." and added fields 53 "Document Type", 60 "External Document No."
    // NPR5.49/MHA /20190228  CASE 342811 Added partner fields
    // NPR5.50/MHA /20190426  CASE 353079 Added Option "Top-up" to field 10 "Entry Type"

    Caption = 'Retail Voucher Entry';
    DrillDownPageID = "NpRv Voucher Entries";
    LookupPageID = "NpRv Voucher Entries";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"Voucher No.";Code[20])
        {
            Caption = 'Voucher No.';
            TableRelation = "NpRv Voucher";
        }
        field(10;"Entry Type";Option)
        {
            Caption = 'Entry Type';
            Description = 'NPR5.49,NPR5.50';
            OptionCaption = ',Issue Voucher,Payment,Manual Archive,Partner Issue Voucher,Partner Payment,Top-up';
            OptionMembers = ,"Issue Voucher",Payment,"Manual Archive","Partner Issue Voucher","Partner Payment","Top-up";
        }
        field(15;"Voucher Type";Code[20])
        {
            Caption = 'Voucher Type';
            TableRelation = "NpRv Voucher Type";
        }
        field(17;Positive;Boolean)
        {
            Caption = 'Positive';
        }
        field(20;Amount;Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(25;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(30;Open;Boolean)
        {
            Caption = 'Open';
        }
        field(40;"Remaining Amount";Decimal)
        {
            Caption = 'Remaining Amount';
            DecimalPlaces = 0:5;
        }
        field(50;"Register No.";Code[10])
        {
            Caption = 'Register No.';
            TableRelation = Register."Register No.";
        }
        field(53;"Document Type";Option)
        {
            Caption = 'Document Type';
            Description = 'NPR5.48';
            OptionCaption = 'Audit Roll,Invoice';
            OptionMembers = "Audit Roll",Invoice;
        }
        field(55;"Document No.";Code[20])
        {
            Caption = 'Document No.';
            Description = 'NPR5.48';
        }
        field(60;"External Document No.";Code[50])
        {
            Caption = 'External Document No.';
            Description = 'NPR5.48';
            Editable = false;
            NotBlank = true;
        }
        field(65;"User ID";Code[50])
        {
            Caption = 'User ID';
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(67;"Partner Code";Code[20])
        {
            Caption = 'Partner Code';
            Description = 'NPR5.49';
            TableRelation = "NpRv Partner";
        }
        field(70;"Closed by Entry No.";Integer)
        {
            BlankZero = true;
            Caption = 'Closed by Entry No.';
        }
        field(75;"Closed by Partner Code";Code[20])
        {
            Caption = 'Closed by Partner Code';
            Description = 'NPR5.49';
            TableRelation = "NpRv Partner";
        }
        field(80;"Partner Clearing";Boolean)
        {
            Caption = 'Partner Clearing';
            Description = 'NPR5.49';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Voucher No.")
        {
            SumIndexFields = Amount,"Remaining Amount";
        }
        key(Key3;"Entry Type","Register No.","Document No.")
        {
        }
    }

    fieldgroups
    {
    }
}

