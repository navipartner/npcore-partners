table 6150773 "NPR Vipps Mp Webhook"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Vipps Mp Webhook List";
    LookupPageId = "NPR Vipps Mp Webhook List";
    Extensible = False;
    Access = Internal;

    fields
    {
        field(1; "Webhook Reference"; Text[250])
        {
            Caption = 'Webhook Reference';
            DataClassification = CustomerContent;
        }
        field(2; "Webhook Id"; Text[250])
        {
            Caption = 'Webhook Id';
            DataClassification = CustomerContent;
        }
        field(3; "Webhook Secret"; Text[200])
        {
            Caption = 'Webhook Secret';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(4; "Webhook Url"; Text[500])
        {
            Caption = 'Webhook Url';
            DataClassification = CustomerContent;
        }
        field(5; "Merchant Serial Number"; Text[10])
        {
            Caption = 'Merchant Serial Number';
            DataClassification = CustomerContent;
        }
        field(6; "OnPrem AF Credential Id"; Text[100])
        {
            Caption = 'AF Credential Id';
            DataClassification = CustomerContent;
        }
        field(7; "OnPrem AF Credential Key"; Text[50])
        {
            Caption = 'AF Credential Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }

    }

    keys
    {
        key(Key1; "Webhook Reference")
        {
        }
    }
}