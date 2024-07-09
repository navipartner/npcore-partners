table 6014668 "NPR HWC Printer"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Hardware Connector Report Printers';

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
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Payload requires integers, hence use new field: Printer Paper Height.';
            Caption = 'Printer Paper Height';
            DecimalPlaces = 0 : 2;
            DataClassification = CustomerContent;
        }
        field(8; "Paper Width"; Decimal)
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            Caption = 'Printer Paper Width';
            ObsoleteReason = 'Payload requires integers, hence use new field: Printer Paper Width.';
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
        field(11; "Printer Paper Height"; Integer)
        {
            Caption = 'Printer Paper Height';
            DataClassification = CustomerContent;
        }
        field(12; "Printer Paper Width"; Integer)
        {
            Caption = 'Printer Paper Width';
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

    trigger OnInsert()
    begin
        CheckCustomSetup();
    end;

    trigger OnModify()
    begin
        CheckCustomSetup();
    end;

    local procedure CheckCustomSetup()
    var
        ErrCustomHeightWidth: Label 'When using paper size: Custom, you must enter values greater than 0 for both height and width.';
    begin
        if "Paper size" = "Paper Size"::Custom then begin
            if not (("Printer Paper Height" > 0) and ("Printer Paper Width" > 0)) then
                Error(ErrCustomHeightWidth);
        end;
    end;
}
