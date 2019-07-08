table 6059965 "MPOS Adyen Transactions"
{
    // NPR5.31/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence

    Caption = 'MPOS Adyen Transactions';

    fields
    {
        field(1;"Transaction No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Transaction No.';
        }
        field(10;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
        }
        field(11;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
        }
        field(12;"Sales Line No.";Integer)
        {
            Caption = 'Sales Line No.';
        }
        field(13;"Session Id";Code[20])
        {
            Caption = 'Session Id';
        }
        field(14;"Merchant Reference";Code[50])
        {
            Caption = 'Merchant Reference';
        }
        field(15;"Payment Amount In Cents";Integer)
        {
            Caption = 'Payment Amount In Cents';
        }
        field(16;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(17;"Created Date";DateTime)
        {
            Caption = 'Created Date';
        }
        field(18;"Modify Date";DateTime)
        {
            Caption = 'Modify Date';
        }
        field(19;Amount;Decimal)
        {
            Caption = 'Amount';
        }
        field(20;Handled;Boolean)
        {
            Caption = 'Handled';
        }
        field(21;"Transaction Type";Option)
        {
            Caption = 'Transaction Type';
            OptionCaption = 'PAY,CASH,REFUND';
            OptionMembers = PAY,CASH,REFUND;
        }
        field(22;"Payment Gateway";Code[10])
        {
            Caption = 'Payment Gateway';
            TableRelation = "MPOS Payment Gateway";
        }
        field(23;"Merchant Id";Text[30])
        {
            Caption = 'Merchant Id';
        }
        field(100;"Callback Result";Code[20])
        {
            Caption = 'Callback Result';
        }
        field(101;"Callback CS";Code[20])
        {
            Caption = 'Callback CS';
        }
        field(102;"Callback Merchant Account";Text[50])
        {
            Caption = 'Callback Merchant Account';
        }
        field(103;"Callback Message";Text[250])
        {
            Caption = 'Callback Message';
        }
        field(104;"Callback Session Id";Code[20])
        {
            Caption = 'Callback Session Id';
        }
        field(105;"Callback Merchant Reference";Code[50])
        {
            Caption = 'Callback Merchant Reference';
        }
        field(106;"Callback Code";Code[20])
        {
            Caption = 'Callback Code';
        }
        field(107;"Callback Panseq";Code[10])
        {
            Caption = 'Callback Panseq';
        }
        field(108;"Callback POS Entry Mode";Code[10])
        {
            Caption = 'Callback POS Entry Mode';
        }
        field(109;"Callback Card Summary";Code[10])
        {
            Caption = 'Callback Card Summary';
        }
        field(110;"Callback PSP Auth Code";Code[10])
        {
            Caption = 'Callback PSP Auth Code';
        }
        field(111;"Callback Amount Value";Integer)
        {
            Caption = 'Callback Amount Value';
        }
        field(112;"Callback Issuer Country";Code[10])
        {
            Caption = 'Callback Issuer Country';
        }
        field(113;"Callback Expiry Month";Code[2])
        {
            Caption = 'Callback Expiry Month';
        }
        field(114;"Callback Card Holder Verificat";Code[10])
        {
            Caption = 'Callback Card Holder Verificat';
        }
        field(115;"Callback Card Scheme";Text[30])
        {
            Caption = 'Callback Card Scheme';
        }
        field(116;"Callback Card Bin";Code[10])
        {
            Caption = 'Callback Card Bin';
        }
        field(117;"Callback Application Label";Code[10])
        {
            Caption = 'Callback Application Label';
        }
        field(118;"Callback Payment Meth Variant";Code[20])
        {
            Caption = 'Callback Payment Meth Variant';
        }
        field(119;"Callback Tender Reference";Text[30])
        {
            Caption = 'Callback Tender Reference';
        }
        field(120;"Callback App Preferred Name";Text[30])
        {
            Caption = 'Callback App Preferred Name';
        }
        field(121;"Callback Aid Code";Code[20])
        {
            Caption = 'Callback Aid Code';
        }
        field(122;"Callback Org Amount Value";Integer)
        {
            Caption = 'Callback Org Amount Value';
        }
        field(123;"Callback Tx Time";Code[20])
        {
            Caption = 'Callback Tx Time';
        }
        field(124;"Callback Tx Date";Code[20])
        {
            Caption = 'Callback Tx Date';
        }
        field(125;"Callback Terminal Id";Code[50])
        {
            Caption = 'Callback Terminal Id';
        }
        field(126;"Callback Payment Method";Code[20])
        {
            Caption = 'Callback Payment Method';
        }
        field(127;"Callback PSP Reference";Code[20])
        {
            Caption = 'Callback PSP Reference';
        }
        field(128;"Callback Mid";Integer)
        {
            Caption = 'Callback Mid';
        }
        field(129;"Callback Expiry Year";Integer)
        {
            Caption = 'Callback Expiry Year';
        }
        field(130;"Callback Card Type";Code[20])
        {
            Caption = 'Callback Card Type';
        }
        field(131;"Callback Org Amount Currency";Code[10])
        {
            Caption = 'Callback Org Amount Currency';
        }
        field(132;"Callback Card Holder Name";Text[30])
        {
            Caption = 'Callback Card Holder Name';
        }
        field(133;"Callback Amount Currency";Code[10])
        {
            Caption = 'Callback Amount Currency';
        }
        field(134;"Callback Transaction Type";Code[50])
        {
            Caption = 'Callback Transaction Type';
        }
        field(200;"Request Json";BLOB)
        {
            Caption = 'Request Json';
        }
        field(201;"Response Json";BLOB)
        {
            Caption = 'Response Json';
        }
    }

    keys
    {
        key(Key1;"Transaction No.")
        {
        }
    }

    fieldgroups
    {
    }
}

