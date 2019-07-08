table 6151162 "MM Loyalty Ledger Entry (Srvr)"
{
    // MM1.37/TSA/20190328  CASE 338215 Transport T0009 - 28 March 2019
    // MM1.38/TSA /20190522 CASE 338215 Added Company Name, some adjustments

    Caption = 'Loyalty Server Store Ledger';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(9;"Entry Type";Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Receipt,Reserve,Cancel Reserve,Reconcile';
            OptionMembers = RECEIPT,RESERVE,CANCEL_RESERVE,RECONCILE;
        }
        field(10;"POS Store Code";Code[10])
        {
            Caption = 'POS Store Code';
        }
        field(11;"POS Unit Code";Code[10])
        {
            Caption = 'POS Unit Code';
        }
        field(20;"Card Number";Text[50])
        {
            Caption = 'Card Number';
        }
        field(25;"Reference Number";Code[20])
        {
            Caption = 'Reference Number';
        }
        field(27;"Foreign Transaction Id";Text[50])
        {
            Caption = 'Foreign Transaction Id';
        }
        field(30;"Transaction Date";Date)
        {
            Caption = 'Transaction Date';
        }
        field(31;"Transaction Time";Time)
        {
            Caption = 'Transaction Time';
        }
        field(40;"Authorization Code";Text[40])
        {
            Caption = 'Authorization Code';
        }
        field(50;"Earned Points";Integer)
        {
            Caption = 'Earned Points';
        }
        field(51;"Burned Points";Integer)
        {
            Caption = 'Burned Points';
        }
        field(52;Balance;Integer)
        {
            Caption = 'Balance';
        }
        field(80;"Company Name";Text[80])
        {
            Caption = 'Company Name';
        }
        field(1000;"Reservation is Captured";Boolean)
        {
            CalcFormula = Exist("MM Membership Points Entry" WHERE ("Authorization Code"=FIELD("Authorization Code"),
                                                                    "Entry Type"=CONST(CAPTURE)));
            Caption = 'Reservation is Captured';
            Editable = false;
            FieldClass = FlowField;
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

