table 6014689 "NPR MPOS Report Printer"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'MPOS Report Printers';

    fields
    {
        field(1; ID; Code[250])
        {
            Caption = 'Printer ID';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "LAN IP"; Text[50])
        {
            Caption = 'LAN IP';
            NotBlank = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Regex: Codeunit "NPR Regex";
            begin
                if not Regex.IsMatch(Rec."LAN IP", '^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$') then
                    Rec.FieldError("LAN IP");
            end;
        }
        field(5; "Paper Source"; Enum "Printer Paper Source Kind")
        {
            Caption = 'Paper Source';
            InitValue = "AutomaticFeed";
            DataClassification = CustomerContent;
        }
        field(6; "Paper Size"; Enum "Printer Paper Kind")
        {
            Caption = 'Paper Size';
            InitValue = "A4";
            DataClassification = CustomerContent;
        }
        field(7; "Paper Height"; Decimal)
        {
            Caption = 'Printer Paper Height';
            DecimalPlaces = 0 : 2;
            DataClassification = CustomerContent;
        }
        field(8; "Paper Width"; Decimal)
        {
            Caption = 'Printer Paper Width';
            DecimalPlaces = 0 : 2;
            DataClassification = CustomerContent;
        }
        field(9; "Paper Unit"; Enum "NPR Printer Paper Unit")
        {
            Caption = 'Printer Paper Unit';
            InitValue = "Millimeters";
            DataClassification = CustomerContent;
        }
        field(10; Landscape; Boolean)
        {
            Caption = 'Landscape';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(pk; ID)
        {
            Clustered = true;
        }
    }
}