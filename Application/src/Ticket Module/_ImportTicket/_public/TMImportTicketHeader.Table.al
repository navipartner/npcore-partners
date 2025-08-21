table 6150753 "NPR TM ImportTicketHeader"
{
    DataClassification = CustomerContent;
    Access = Public;
    Caption = 'Ticket Import (Header)';

    fields
    {
        field(1; OrderId; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Order ID';
        }
        field(10; SalesDate; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Date';
        }
        field(20; PaymentReference; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Reference';
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
        field(33; TicketHolderPreferredLang; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Holder Preferred Language';
        }
        field(100; TotalAmount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Amount';
        }
        field(110; TotalAmountInclVat; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Amount Incl. VAT';
        }

        field(120; TotalDiscountAmountInclVat; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Discount Amount Incl. VAT';
        }
        field(130; CurrencyCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
        }
        field(132; TotalAmountLcyInclVat; decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Amount Incl. VAT (LCY)';
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
    }

    keys
    {
        key(Key1; OrderId, JobId)
        {
            Clustered = true;
        }
        key(Job; JobId) { }

        key(Token; TicketRequestToken) { }
    }

    trigger OnDelete()
    var
        ImportLines: Record "NPR TM ImportTicketLine";
    begin
        ImportLines.SetCurrentKey(JobId);
        ImportLines.SetFilter(JobId, '=%1', Rec.JobId);
        ImportLines.DeleteAll(true);
    end;

}