table 6150691 "NPR EFT Adyen Local Unit Setup"
{
    Access = Internal;
    Caption = 'EFT Adyen Local POS Unit Setup';
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
    }
}