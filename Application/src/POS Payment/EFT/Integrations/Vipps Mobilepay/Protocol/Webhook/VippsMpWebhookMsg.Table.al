table 6150770 "NPR Vipps Mp Webhook Msg"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = False;

    fields
    {
        field(2; "Message"; BLOB)
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }
        field(3; ReceivedAt; DateTime)
        {
            Caption = 'ReceivedAt';
            DataClassification = CustomerContent;
        }

        field(4; "Webhook Reference"; Text[250])
        {
            Caption = 'Webhook Reference';
            DataClassification = CustomerContent;
            TableRelation = "NPR Vipps Mp Webhook";
        }
        field(5; "Event Type"; Option)
        {
            Caption = 'Event Type';
            DataClassification = CustomerContent;
            OptionMembers = "QrScan","ePayment";
            OptionCaption = 'Qr Scan,ePayment';
        }
        field(6; "Operation Reference"; Text[250])
        {
            Caption = 'Operation Reference';
            DataClassification = CustomerContent;
        }
        field(7; "Error"; Boolean)
        {
            Caption = 'Error';
            DataClassification = CustomerContent;
        }

        field(8; Verified; Boolean)
        {
            Caption = 'Verified';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; "Webhook Reference", "Operation Reference", "Event Type")
        {

        }
        key(Key2; ReceivedAt, Error)
        {
            Unique = False;
        }


    }
}