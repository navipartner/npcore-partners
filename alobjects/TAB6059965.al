table 6059965 "MPOS Adyen Transactions"
{
    // NPR5.31/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence

    Caption = 'MPOS Adyen Transactions';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Transaction No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(10; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(11; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(12; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;
        }
        field(13; "Session Id"; Code[20])
        {
            Caption = 'Session Id';
            DataClassification = CustomerContent;
        }
        field(14; "Merchant Reference"; Code[50])
        {
            Caption = 'Merchant Reference';
            DataClassification = CustomerContent;
        }
        field(15; "Payment Amount In Cents"; Integer)
        {
            Caption = 'Payment Amount In Cents';
            DataClassification = CustomerContent;
        }
        field(16; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(17; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
        field(18; "Modify Date"; DateTime)
        {
            Caption = 'Modify Date';
            DataClassification = CustomerContent;
        }
        field(19; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(20; Handled; Boolean)
        {
            Caption = 'Handled';
            DataClassification = CustomerContent;
        }
        field(21; "Transaction Type"; Option)
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
            OptionCaption = 'PAY,CASH,REFUND';
            OptionMembers = PAY,CASH,REFUND;
        }
        field(22; "Payment Gateway"; Code[10])
        {
            Caption = 'Payment Gateway';
            DataClassification = CustomerContent;
            TableRelation = "MPOS Payment Gateway";
        }
        field(23; "Merchant Id"; Text[30])
        {
            Caption = 'Merchant Id';
            DataClassification = CustomerContent;
        }
        field(100; "Callback Result"; Code[20])
        {
            Caption = 'Callback Result';
            DataClassification = CustomerContent;
        }
        field(101; "Callback CS"; Code[20])
        {
            Caption = 'Callback CS';
            DataClassification = CustomerContent;
        }
        field(102; "Callback Merchant Account"; Text[50])
        {
            Caption = 'Callback Merchant Account';
            DataClassification = CustomerContent;
        }
        field(103; "Callback Message"; Text[250])
        {
            Caption = 'Callback Message';
            DataClassification = CustomerContent;
        }
        field(104; "Callback Session Id"; Code[20])
        {
            Caption = 'Callback Session Id';
            DataClassification = CustomerContent;
        }
        field(105; "Callback Merchant Reference"; Code[50])
        {
            Caption = 'Callback Merchant Reference';
            DataClassification = CustomerContent;
        }
        field(106; "Callback Code"; Code[20])
        {
            Caption = 'Callback Code';
            DataClassification = CustomerContent;
        }
        field(107; "Callback Panseq"; Code[10])
        {
            Caption = 'Callback Panseq';
            DataClassification = CustomerContent;
        }
        field(108; "Callback POS Entry Mode"; Code[10])
        {
            Caption = 'Callback POS Entry Mode';
            DataClassification = CustomerContent;
        }
        field(109; "Callback Card Summary"; Code[10])
        {
            Caption = 'Callback Card Summary';
            DataClassification = CustomerContent;
        }
        field(110; "Callback PSP Auth Code"; Code[10])
        {
            Caption = 'Callback PSP Auth Code';
            DataClassification = CustomerContent;
        }
        field(111; "Callback Amount Value"; Integer)
        {
            Caption = 'Callback Amount Value';
            DataClassification = CustomerContent;
        }
        field(112; "Callback Issuer Country"; Code[10])
        {
            Caption = 'Callback Issuer Country';
            DataClassification = CustomerContent;
        }
        field(113; "Callback Expiry Month"; Code[2])
        {
            Caption = 'Callback Expiry Month';
            DataClassification = CustomerContent;
        }
        field(114; "Callback Card Holder Verificat"; Code[10])
        {
            Caption = 'Callback Card Holder Verificat';
            DataClassification = CustomerContent;
        }
        field(115; "Callback Card Scheme"; Text[30])
        {
            Caption = 'Callback Card Scheme';
            DataClassification = CustomerContent;
        }
        field(116; "Callback Card Bin"; Code[10])
        {
            Caption = 'Callback Card Bin';
            DataClassification = CustomerContent;
        }
        field(117; "Callback Application Label"; Code[10])
        {
            Caption = 'Callback Application Label';
            DataClassification = CustomerContent;
        }
        field(118; "Callback Payment Meth Variant"; Code[20])
        {
            Caption = 'Callback Payment Meth Variant';
            DataClassification = CustomerContent;
        }
        field(119; "Callback Tender Reference"; Text[30])
        {
            Caption = 'Callback Tender Reference';
            DataClassification = CustomerContent;
        }
        field(120; "Callback App Preferred Name"; Text[30])
        {
            Caption = 'Callback App Preferred Name';
            DataClassification = CustomerContent;
        }
        field(121; "Callback Aid Code"; Code[20])
        {
            Caption = 'Callback Aid Code';
            DataClassification = CustomerContent;
        }
        field(122; "Callback Org Amount Value"; Integer)
        {
            Caption = 'Callback Org Amount Value';
            DataClassification = CustomerContent;
        }
        field(123; "Callback Tx Time"; Code[20])
        {
            Caption = 'Callback Tx Time';
            DataClassification = CustomerContent;
        }
        field(124; "Callback Tx Date"; Code[20])
        {
            Caption = 'Callback Tx Date';
            DataClassification = CustomerContent;
        }
        field(125; "Callback Terminal Id"; Code[50])
        {
            Caption = 'Callback Terminal Id';
            DataClassification = CustomerContent;
        }
        field(126; "Callback Payment Method"; Code[20])
        {
            Caption = 'Callback Payment Method';
            DataClassification = CustomerContent;
        }
        field(127; "Callback PSP Reference"; Code[20])
        {
            Caption = 'Callback PSP Reference';
            DataClassification = CustomerContent;
        }
        field(128; "Callback Mid"; Integer)
        {
            Caption = 'Callback Mid';
            DataClassification = CustomerContent;
        }
        field(129; "Callback Expiry Year"; Integer)
        {
            Caption = 'Callback Expiry Year';
            DataClassification = CustomerContent;
        }
        field(130; "Callback Card Type"; Code[20])
        {
            Caption = 'Callback Card Type';
            DataClassification = CustomerContent;
        }
        field(131; "Callback Org Amount Currency"; Code[10])
        {
            Caption = 'Callback Org Amount Currency';
            DataClassification = CustomerContent;
        }
        field(132; "Callback Card Holder Name"; Text[30])
        {
            Caption = 'Callback Card Holder Name';
            DataClassification = CustomerContent;
        }
        field(133; "Callback Amount Currency"; Code[10])
        {
            Caption = 'Callback Amount Currency';
            DataClassification = CustomerContent;
        }
        field(134; "Callback Transaction Type"; Code[50])
        {
            Caption = 'Callback Transaction Type';
            DataClassification = CustomerContent;
        }
        field(200; "Request Json"; BLOB)
        {
            Caption = 'Request Json';
            DataClassification = CustomerContent;
        }
        field(201; "Response Json"; BLOB)
        {
            Caption = 'Response Json';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Transaction No.")
        {
        }
    }

    fieldgroups
    {
    }
}

