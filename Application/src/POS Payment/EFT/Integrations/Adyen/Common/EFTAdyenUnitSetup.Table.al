table 6150913 "NPR EFT Adyen Unit Setup"
{
    Access = Internal;
    Caption = 'EFT Adyen Unit Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
            Caption = 'POS Unit No.';
        }
        field(2; "Terminal LAN IP"; Text[15])
        {
            DataClassification = CustomerContent;
            Caption = 'Terminal LAN IP';

            trigger OnValidate()
            var
                RegEx: Codeunit "NPR RegEx";
                InvalidIPLbl: Label 'Invalid IP Address';
            begin
                // validate with regex that IPv4 address is valid
                if not Regex.IsMatch(Rec."Terminal LAN IP", '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') then
                    FieldError(Rec."Terminal LAN IP", InvalidIPLbl);
            end;
        }
        field(3; POIID; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Poi Id';
        }
        field(4; "In Person Store Id"; Text[250])
        {
            Caption = 'Store Id';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "POS Unit No.")
        {
        }
    }
}