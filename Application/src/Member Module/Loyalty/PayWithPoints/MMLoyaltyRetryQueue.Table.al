table 6150899 "NPR MM LoyaltyRetryQueue"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Loyalty Retry Queue';

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; SoapAction; Text[250])
        {
            Caption = 'SOAP Action';
            DataClassification = CustomerContent;
        }
        field(20; RetryCount; Integer)
        {
            Caption = 'Retry Count';
            DataClassification = CustomerContent;
        }
        field(30; FailedDateTime; DateTime)
        {
            Caption = 'Failed Date Time';
            DataClassification = CustomerContent;
        }
        field(40; NextRetryDateTime; DateTime)
        {
            Caption = 'Next Retry Date Time';
            DataClassification = CustomerContent;
        }
        field(50; LastError; Text[1020])
        {
            Caption = 'Last Error';
            DataClassification = CustomerContent;
        }
        field(60; RequestXml; Blob)
        {
            Caption = 'Request XML';
            DataClassification = CustomerContent;
        }
        field(80; SalesTicketNo; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(81; SalesId; Guid)
        {
            Caption = 'Sales ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }

        key(Key2; NextRetryDateTime)
        {
        }
    }



}