table 6184516 "NPR EFT Trx Async Req."
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Background sessions are too limited in BC Cloud so we are shifting to page background tasks for EFT requests';

    Caption = 'EFT Transaction Async Request';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Request Entry No"; Integer)
        {
            Caption = 'Request Entry No';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Transaction Request";
        }
        field(20; Done; Boolean)
        {
            Caption = 'Done';
            DataClassification = CustomerContent;
        }
        field(30; "Abort Requested"; Boolean)
        {
            Caption = 'Abort Requested';
            DataClassification = CustomerContent;
        }
        field(40; Metadata; BLOB)
        {
            Caption = 'Metadata';
            DataClassification = CustomerContent;
        }
        field(50; "Hardware ID"; Text[200])
        {
            Caption = 'Hardware ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Request Entry No")
        {
        }
        key(Key2; "Hardware ID")
        {
        }
    }

    fieldgroups
    {
    }
}

