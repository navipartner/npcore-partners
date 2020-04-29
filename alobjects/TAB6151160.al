table 6151160 "MM Register Sales Buffer"
{
    // MM1.37/TSA /20190130 CASE 338215 Initial Version

    Caption = 'Register Sales Buffer';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Authorization,Sales,Return Sales,Payment,Refund,Void,Not Applicable';
            OptionMembers = AUTHORIZATION,SALES,RETURN,PAYMENT,REFUND,VOID,NA;
        }
        field(11;"Authorization Code";Text[40])
        {
            Caption = 'Authorization Code';
        }
        field(20;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(21;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
        }
        field(22;Quantity;Decimal)
        {
            Caption = 'Quantity';
        }
        field(23;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(30;"Total Amount";Decimal)
        {
            Caption = 'Total Amount';
        }
        field(31;"Total Points";Integer)
        {
            Caption = 'Total Points';
        }
        field(35;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

