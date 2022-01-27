table 6184506 "NPR EFT Trx Async Resp."
{
    Access = Internal;
    // NPR5.48/MMV /20190124 CASE 341237 Created object
    // NPR5.54/MMV /20200218 CASE 387990 Added "Transaction Started" bool to track how critical error is.

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

