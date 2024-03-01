table 6150771 "NPR Vipps Mp QrCallback"
{
    Access = Internal;
    Extensible = False;
    DataClassification = CustomerContent;
    LookupPageId = "NPR Vipps Mp QrCallback List";
    DrillDownPageId = "NPR Vipps Mp QrCallback List";

    fields
    {
        field(1; "Merchant Qr Id"; Text[250])
        {
            Caption = 'Merchant QR Id';
            DataClassification = CustomerContent;
        }
        field(2; "Merchant Serial Number"; Text[10])
        {
            Caption = 'Merchant Serial No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Vipps Mp Store";
        }
        field(3; "Location Description"; Text[50])
        {
            Caption = 'Location Description';
            DataClassification = CustomerContent;
        }
        field(4; "Qr Content"; Text[500])
        {
            Caption = 'QR Content';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key("Key1"; "Merchant Qr Id")
        {

        }
    }
}