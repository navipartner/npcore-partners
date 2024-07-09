table 6184506 "NPR EFT Trx Async Resp."
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Background sessions are too limited in BC Cloud so we are shifting to page background tasks for EFT requests';

    Caption = 'EFT Transaction Async Response';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Request Entry No"; Integer)
        {
            Caption = 'Request Entry No';
            DataClassification = CustomerContent;
        }
        field(2; Response; BLOB)
        {
            Caption = 'Response';
            DataClassification = CustomerContent;
        }
        field(3; "Error"; Boolean)
        {
            Caption = 'Error';
            DataClassification = CustomerContent;
        }
        field(4; "Error Text"; Text[250])
        {
            Caption = 'Error Text';
            DataClassification = CustomerContent;
        }
        field(5; "Transaction Started"; Boolean)
        {
            Caption = 'Transaction Started';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Request Entry No")
        {
        }
    }

    fieldgroups
    {
    }
}

