table 6184516 "NPR EFT Trx Async Req."
{
    // NPR5.53/MMV /20191120 CASE 377533 Created object
    // NPR5.54/MMV /20200219 CASE 364340 Added fields 40, 50

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

