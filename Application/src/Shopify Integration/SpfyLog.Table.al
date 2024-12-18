#if not BC17
table 6150993 "NPR Spfy Log"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Shopify Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(20; "Log Source"; Enum "NPR Spfy Log Source")
        {
            Caption = 'Log Source';
            DataClassification = CustomerContent;
        }
        field(30; "Message Type"; Enum "NPR Spfy Message Type")
        {
            Caption = 'Log Type';
            DataClassification = CustomerContent;
        }
        field(40; "Message Text"; Text[200])
        {
            Caption = 'Message Text';
            DataClassification = CustomerContent;
        }
        field(50; "Message Blob"; Blob)
        {
            Caption = 'Message Blob';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Log Source")
        {
        }
    }
}
#endif
