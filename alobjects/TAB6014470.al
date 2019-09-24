table 6014470 "Pacsoft Shipment Doc. Services"
{
    // PS1.00/LS/20141201  CASE 200150 Pacsoft Module

    Caption = 'Pacsoft Shipment Document Services';

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            Caption = 'Entry No.';
        }
        field(2;"Shipping Agent Code";Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(3;"Shipping Agent Service Code";Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE ("Shipping Agent Code"=FIELD("Shipping Agent Code"));
        }
        field(20;Description;Text[50])
        {
            CalcFormula = Lookup("Shipping Agent Services".Description WHERE ("Shipping Agent Code"=FIELD("Shipping Agent Code"),
                                                                              Code=FIELD("Shipping Agent Service Code")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21;Amount;Decimal)
        {
            Caption = 'Amount';
            Enabled = false;
        }
        field(22;Reference;Text[50])
        {
            Caption = 'Reference';
            Enabled = false;
        }
        field(23;"Reference Type";Option)
        {
            Caption = 'Reference Type';
            Enabled = false;
            OptionCaption = ' ,TXT,OCR';
            OptionMembers = " ",TXT,OCR;
        }
        field(24;Miscellaneous;Text[80])
        {
            Caption = 'Miscellaneous';
            Enabled = false;
        }
        field(25;"Account No.";Code[20])
        {
            Caption = 'Account No.';
            Enabled = false;
        }
        field(26;"Account Type";Text[5])
        {
            Caption = 'Account Type';
            Enabled = false;
            ValuesAllowed = 'ACCDK','BG','PG','KONTO';
        }
    }

    keys
    {
        key(Key1;"Entry No.","Shipping Agent Code","Shipping Agent Service Code")
        {
        }
    }

    fieldgroups
    {
    }
}

