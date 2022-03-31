table 6014668 "NPR HWC Printer"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Hardware Connector Printers';

    fields
    {
        field(1; ID; Code[250])
        {
            Caption = 'Printer ID';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[250])
        {
            Caption = 'Printer Name';
            NotBlank = true;
            DataClassification = CustomerContent;
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