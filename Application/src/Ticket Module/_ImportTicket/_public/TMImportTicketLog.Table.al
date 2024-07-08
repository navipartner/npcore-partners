table 6150757 "NPR TM ImportTicketLog"
{
    DataClassification = CustomerContent;
    Access = Public;
    Caption = 'Import Ticket Log';

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10; JobId; Code[40])
        {
            DataClassification = CustomerContent;
            Caption = 'Job ID';
        }
        field(20; FileName; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'File Name';
        }
        field(30; ImportDuration; Duration)
        {
            DataClassification = CustomerContent;
            Caption = 'Import Duration';
        }
        field(40; Success; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Success';
        }
        field(45; ResponseMessage; Text[512])
        {
            DataClassification = CustomerContent;
            Caption = 'Response Message';
        }
        field(50; NumberOfTickets; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Number of Tickets';
        }
        field(60; ImportedBy; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Import by';
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
        key(Key2; JobId) { }
    }

    trigger OnDelete()
    var
        ImportHeader: Record "NPR TM ImportTicketHeader";
    begin
        ImportHeader.SetCurrentKey(JobId);
        ImportHeader.SetFilter(JobId, '=%1', Rec.JobId);
        ImportHeader.DeleteAll(true);
    end;
}