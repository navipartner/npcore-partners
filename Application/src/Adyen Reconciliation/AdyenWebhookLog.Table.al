table 6150881 "NPR Adyen Webhook Log"
{
    Access = Internal;
    Caption = 'Adyen Webhook Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(10; "Creation Date"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Creation Date';
        }
        field(20; "Webhook Request Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Webhook Request ID';
            TableRelation = "NPR Adyen Webhook"."Entry No.";
        }
        field(30; Type; Enum "NPR Adyen Webhook Log Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(40; Success; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Success';
        }
        field(50; Description; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
