table 6059968 "NPR MPOS Nets Transactions"
{
    Caption = 'MPOS Nets Transactions';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Removing MPOS Payment Gateway';
    ObsoleteTag = 'Removing MPOS Payment Gateway';

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
            OptionCaption = 'PAY,CASH,REFUND,CANCEL';
            OptionMembers = PAY,CASH,REFUND,CANCEL;
        }
        field(22; "Payment Gateway"; Code[10])
        {
            Caption = 'Payment Gateway';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(23; "Merchant Id"; Text[30])
        {
            Caption = 'Merchant Id';
            DataClassification = CustomerContent;
        }
        field(24; "Transaction Type Id"; Integer)
        {
            Caption = 'Transaction Type Id';
            DataClassification = CustomerContent;
        }
        field(100; "Callback Result"; Integer)
        {
            Caption = 'Callback Result';
            DataClassification = CustomerContent;
        }
        field(101; "Callback AccumulatorUpdate"; Integer)
        {
            Caption = 'Callback AccumulatorUpdate';
            DataClassification = CustomerContent;
        }
        field(102; "Callback IssuerId"; Integer)
        {
            Caption = 'Callback IssuerId';
            DataClassification = CustomerContent;
        }
        field(103; "Callback TruncatedPan"; Text[30])
        {
            Caption = 'Callback TruncatedPan';
            DataClassification = CustomerContent;
        }
        field(104; "Callback EncryptedPan"; Text[250])
        {
            Caption = 'Callback EncryptedPan';
            DataClassification = CustomerContent;
        }
        field(105; "Callback Timestamp"; Text[30])
        {
            Caption = 'Callback Timestamp';
            DataClassification = CustomerContent;
        }
        field(106; "Callback VerificationMethod"; Integer)
        {
            Caption = 'Callback VerificationMethod';
            DataClassification = CustomerContent;
        }
        field(107; "Callback SessionNumber"; Text[30])
        {
            Caption = 'Callback SessionNumber';
            DataClassification = CustomerContent;
        }
        field(108; "Callback StanAuth"; Text[30])
        {
            Caption = 'Callback StanAuth';
            DataClassification = CustomerContent;
        }
        field(109; "Callback SequenceNumber"; Text[30])
        {
            Caption = 'Callback SequenceNumber';
            DataClassification = CustomerContent;
        }
        field(110; "Callback TotalAmount"; Integer)
        {
            Caption = 'Callback TotalAmount';
            DataClassification = CustomerContent;
        }
        field(111; "Callback TipAmount"; Integer)
        {
            Caption = 'Callback TipAmount';
            DataClassification = CustomerContent;
        }
        field(112; "Callback SurchargeAmount"; Integer)
        {
            Caption = 'Callback SurchargeAmount';
            DataClassification = CustomerContent;
        }
        field(113; "Callback TerminalID"; Text[30])
        {
            Caption = 'Callback TerminalID';
            DataClassification = CustomerContent;
        }
        field(114; "Callback AcquiereMerchantID"; Text[30])
        {
            Caption = 'Callback AcquiereMerchantID';
            DataClassification = CustomerContent;
        }
        field(115; "Callback CardIssuerName"; Text[30])
        {
            Caption = 'Callback CardIssuerName';
            DataClassification = CustomerContent;
        }
        field(116; "Callback TCC"; Text[30])
        {
            Caption = 'Callback TCC';
            DataClassification = CustomerContent;
        }
        field(117; "Callback AID"; Text[30])
        {
            Caption = 'Callback AID';
            DataClassification = CustomerContent;
        }
        field(118; "Callback TVR"; Text[30])
        {
            Caption = 'Callback TVR';
            DataClassification = CustomerContent;
        }
        field(119; "Callback TSI"; Text[30])
        {
            Caption = 'Callback TSI';
            DataClassification = CustomerContent;
        }
        field(120; "Callback ATC"; Text[30])
        {
            Caption = 'Callback ATC';
            DataClassification = CustomerContent;
        }
        field(121; "Callback AED"; Text[30])
        {
            Caption = 'Callback AED';
            DataClassification = CustomerContent;
        }
        field(122; "Callback IAC"; Text[30])
        {
            Caption = 'Callback IAC';
            DataClassification = CustomerContent;
        }
        field(123; "Callback OrganisationNumber"; Text[30])
        {
            Caption = 'Callback OrganisationNumber';
            DataClassification = CustomerContent;
        }
        field(124; "Callback BankAgent"; Text[30])
        {
            Caption = 'Callback BankAgent';
            DataClassification = CustomerContent;
        }
        field(125; "Callback AccountType"; Text[30])
        {
            Caption = 'Callback AccountType';
            DataClassification = CustomerContent;
        }
        field(126; "Callback OptionalData"; Text[250])
        {
            Caption = 'Callback OptionalData';
            DataClassification = CustomerContent;
        }
        field(127; "Callback ResponseCode"; Text[30])
        {
            Caption = 'Callback ResponseCode';
            DataClassification = CustomerContent;
        }
        field(128; "Callback RejectionSource"; Integer)
        {
            Caption = 'Callback RejectionSource';
            DataClassification = CustomerContent;
        }
        field(129; "Callback RejectionReason"; Text[30])
        {
            Caption = 'Callback RejectionReason';
            DataClassification = CustomerContent;
        }
        field(130; "Callback MerchantReference"; Code[50])
        {
            Caption = 'Callback MerchantReference';
            DataClassification = CustomerContent;
        }
        field(131; "Callback StatusDescription"; Text[250])
        {
            Caption = 'Callback StatusDescription';
            DataClassification = CustomerContent;
        }
        field(132; "Callback Receipt 1"; BLOB)
        {
            Caption = 'Callback Receipt 1';
            DataClassification = CustomerContent;
        }
        field(133; "Callback Receipt 2"; BLOB)
        {
            Caption = 'Callback Receipt 2';
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
        field(300; "EFT Transaction Entry No."; Integer)
        {
            Caption = 'EFT Transaction Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Transaction Request";
        }
    }

    keys
    {
        key(Key1; "Transaction No.")
        {
        }
    }
}

