table 6150749 "NPR DK SAF-T Cash Export Line"
{
    Access = Internal;
    Caption = 'SAF-T Cash Export Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Integer)
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR DK SAF-T Cash Exp. Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Task ID"; Guid)
        {
            Caption = 'Task ID';
            DataClassification = CustomerContent;
        }
        field(4; Progress; Integer)
        {
            Caption = 'Progress';
            DataClassification = CustomerContent;
            ExtendedDatatype = Ratio;
        }
        field(5; Status; Enum "NPR DK SAF-T Cash Exp. Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(6; "Master Data"; Boolean)
        {
            Caption = 'Master Data';
            DataClassification = CustomerContent;
        }
        field(7; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(8; "No. Of Retries"; Integer)
        {
            Caption = 'No. Of Retries';
            DataClassification = CustomerContent;
            InitValue = 3;
        }
        field(10; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(11; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(20; "SAF-T File"; Blob)
        {
            Caption = 'SAF-T File';
            DataClassification = CustomerContent;
        }
        field(30; "Server Instance ID"; Integer)
        {
            Caption = 'Server Instance ID';
            DataClassification = CustomerContent;
        }
        field(31; "Session ID"; Integer)
        {
            Caption = 'Session ID';
            DataClassification = CustomerContent;
        }
        field(32; "Created Date/Time"; DateTime)
        {
            Caption = 'Created Date/Time';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; ID, "Line No.")
        {
        }
    }

    trigger OnDelete()
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.SetRange("Record ID", RecordId());
        ActivityLog.DeleteAll();
    end;
}