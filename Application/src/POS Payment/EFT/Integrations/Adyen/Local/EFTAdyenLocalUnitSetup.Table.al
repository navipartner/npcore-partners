table 6150691 "NPR EFT Adyen Local Unit Setup"
{
    Access = Internal;
    Caption = 'EFT Adyen Local POS Unit Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteTag = '2024-09-09';
    ObsoleteReason = 'Use EFT Adyen Unit Setup instead';


    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
            Caption = 'POS Unit No.';
            ObsoleteState = Pending;
            ObsoleteTag = '2024-09-09';
            ObsoleteReason = 'Use EFT Adyen Unit Setup instead';
        }
        field(2; "Terminal LAN IP"; Text[15])
        {
            DataClassification = CustomerContent;
            Caption = 'Terminal LAN IP';
            ObsoleteState = Pending;
            ObsoleteTag = '2024-09-09';
            ObsoleteReason = 'Use EFT Adyen Unit Setup instead';

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
            ObsoleteState = Pending;
            ObsoleteTag = '2024-09-09';
            ObsoleteReason = 'Use EFT Adyen Unit Setup instead';
        }
    }
}