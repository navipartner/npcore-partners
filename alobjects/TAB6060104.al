table 6060104 "Global Sale POS"
{
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name

    Caption = 'Global Sale POS';
    DataPerCompany = false;

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2;"Company Name";Text[50])
        {
            Caption = 'Company Name';
        }
        field(3;"Register No.";Code[20])
        {
            Caption = 'Cash Register No.';
        }
        field(4;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
        }
        field(5;"Returning Company Name";Text[50])
        {
            Caption = 'Returning Company Name';
        }
        field(6;"Audit Roll Line No.";Integer)
        {
            Caption = 'Audit Roll Line No.';
        }
        field(7;"Sales Item No.";Code[20])
        {
            Caption = 'Sales Item No.';
        }
        field(8;"Sales Line No.";Integer)
        {
            Caption = 'Sales Line No.';
        }
        field(9;"Sales Quantity";Decimal)
        {
            Caption = 'Sales Quantity';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Register No.","Sales Ticket No.","Company Name")
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetBarcode() EANNumber: Code[20]
    var
        Utility: Codeunit Utility;
        NPRConfig: Record "Retail Setup";
    begin
        NPRConfig.Get;
        NPRConfig.TestField(NPRConfig."EAN Prefix Exhange Label");
        EANNumber := Utility.CreateEAN(Format("Entry No.", 10), NPRConfig."EAN Prefix Exhange Label");
    end;
}

