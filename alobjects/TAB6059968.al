table 6059968 "MPOS Nets Transactions"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence

    Caption = 'MPOS Nets Transactions';
    DrillDownPageID = "MPOS Nets Transactions List";
    LookupPageID = "MPOS Nets Transactions List";

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
            OptionCaption = 'PAY,CASH,REFUND,CANCEL';
            OptionMembers = PAY,CASH,REFUND,CANCEL;
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
        field(24;"Transaction Type Id";Integer)
        {
            Caption = 'Transaction Type Id';
        }
        field(100;"Callback Result";Integer)
        {
            Caption = 'Callback Result';
        }
        field(101;"Callback AccumulatorUpdate";Integer)
        {
            Caption = 'Callback AccumulatorUpdate';
        }
        field(102;"Callback IssuerId";Integer)
        {
            Caption = 'Callback IssuerId';
        }
        field(103;"Callback TruncatedPan";Text[30])
        {
            Caption = 'Callback TruncatedPan';
        }
        field(104;"Callback EncryptedPan";Text[250])
        {
            Caption = 'Callback EncryptedPan';
        }
        field(105;"Callback Timestamp";Text[30])
        {
            Caption = 'Callback Timestamp';
        }
        field(106;"Callback VerificationMethod";Integer)
        {
            Caption = 'Callback VerificationMethod';
        }
        field(107;"Callback SessionNumber";Text[30])
        {
            Caption = 'Callback SessionNumber';
        }
        field(108;"Callback StanAuth";Text[30])
        {
            Caption = 'Callback StanAuth';
        }
        field(109;"Callback SequenceNumber";Text[30])
        {
            Caption = 'Callback SequenceNumber';
        }
        field(110;"Callback TotalAmount";Integer)
        {
            Caption = 'Callback TotalAmount';
        }
        field(111;"Callback TipAmount";Integer)
        {
            Caption = 'Callback TipAmount';
        }
        field(112;"Callback SurchargeAmount";Integer)
        {
            Caption = 'Callback SurchargeAmount';
        }
        field(113;"Callback TerminalID";Text[30])
        {
            Caption = 'Callback TerminalID';
        }
        field(114;"Callback AcquiereMerchantID";Text[30])
        {
            Caption = 'Callback AcquiereMerchantID';
        }
        field(115;"Callback CardIssuerName";Text[30])
        {
            Caption = 'Callback CardIssuerName';
        }
        field(116;"Callback TCC";Text[30])
        {
            Caption = 'Callback TCC';
        }
        field(117;"Callback AID";Text[30])
        {
            Caption = 'Callback AID';
        }
        field(118;"Callback TVR";Text[30])
        {
            Caption = 'Callback TVR';
        }
        field(119;"Callback TSI";Text[30])
        {
            Caption = 'Callback TSI';
        }
        field(120;"Callback ATC";Text[30])
        {
            Caption = 'Callback ATC';
        }
        field(121;"Callback AED";Text[30])
        {
            Caption = 'Callback AED';
        }
        field(122;"Callback IAC";Text[30])
        {
            Caption = 'Callback IAC';
        }
        field(123;"Callback OrganisationNumber";Text[30])
        {
            Caption = 'Callback OrganisationNumber';
        }
        field(124;"Callback BankAgent";Text[30])
        {
            Caption = 'Callback BankAgent';
        }
        field(125;"Callback AccountType";Text[30])
        {
            Caption = 'Callback AccountType';
        }
        field(126;"Callback OptionalData";Text[250])
        {
            Caption = 'Callback OptionalData';
        }
        field(127;"Callback ResponseCode";Text[30])
        {
            Caption = 'Callback ResponseCode';
        }
        field(128;"Callback RejectionSource";Integer)
        {
            Caption = 'Callback RejectionSource';
        }
        field(129;"Callback RejectionReason";Text[30])
        {
            Caption = 'Callback RejectionReason';
        }
        field(130;"Callback MerchantReference";Code[50])
        {
            Caption = 'Callback MerchantReference';
        }
        field(131;"Callback StatusDescription";Text[250])
        {
            Caption = 'Callback StatusDescription';
        }
        field(132;"Callback Receipt 1";BLOB)
        {
            Caption = 'Callback Receipt 1';
        }
        field(133;"Callback Receipt 2";BLOB)
        {
            Caption = 'Callback Receipt 2';
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

