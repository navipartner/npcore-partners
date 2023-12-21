table 6150756 "NPR TM ImportTicketLine"
{
    DataClassification = CustomerContent;
    Access = Public;
    Caption = 'Ticket Import (Line)';

    fields
    {
        field(1; OrderId; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Order ID';
        }
        field(2; PreAssignedTicketNumber; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Preassigned Ticket Number';
        }
        field(10; ItemReferenceNumber; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Reference Number';
        }
        field(15; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(20; ExpectedVisitDate; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Visit Date';
        }
        field(25; ExpectedVisitTime; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Visit Time';
        }
        field(30; TicketHolderEMail; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Holder Email Address';
        }
        field(32; TicketHolderName; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Holder Name';
        }
        field(40; MembershipNumber; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Membership Number';
        }
        field(42; MemberNumber; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Member Number';
        }
        field(100; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
        }
        field(110; AmountInclVat; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount Incl. VAT';
        }
        field(120; DiscountAmountInclVat; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Discount Amount Incl. VAT';
        }
        field(130; CurrencyCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
        }
        field(132; AmountLcyInclVat; decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount Incl. VAT (LCY)';
        }
        field(500; JobId; Code[40])
        {
            DataClassification = CustomerContent;
            Caption = 'Job ID';
        }
        field(510; TicketRequestToken; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket Request Token';
        }
        field(520; TicketRequestTokenLine; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket Request Token Line';
        }
    }

    keys
    {
        key(Key1; OrderId, JobId, PreAssignedTicketNumber)
        {
            Clustered = true;
        }
        key(Key2; JobId) { }

    }

    fieldgroups
    {
        // Add changes to field groups here
        fieldgroup(primaryFieldGroup; OrderId, PreAssignedTicketNumber) { }
    }


}