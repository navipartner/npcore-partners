table 6184516 "EFT Transaction Async Request"
{
    // NPR5.53/MMV /20191120 CASE 377533 Created object

    Caption = 'EFT Transaction Async Request';

    fields
    {
        field(1;"Request Entry No";Integer)
        {
            Caption = 'Request Entry No';
            TableRelation = "EFT Transaction Request";
        }
        field(20;Done;Boolean)
        {
            Caption = 'Done';
        }
        field(30;"Abort Requested";Boolean)
        {
            Caption = 'Abort Requested';
        }
    }

    keys
    {
        key(Key1;"Request Entry No")
        {
        }
    }

    fieldgroups
    {
    }
}

