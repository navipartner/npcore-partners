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
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Payload requires integers, hence use new field: Printer Paper Height.';
            DecimalPlaces = 0 : 2;
            DataClassification = CustomerContent;
        }
        field(8; "Paper Width"; Decimal)
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Payload requires integers, hence use new field: Printer Paper Width.';
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
        field(11; "Printer Paper Width"; Integer)
        {
            Caption = 'Printer Paper Width';
            DataClassification = CustomerContent;
        }
        field(12; "Printer Paper Height"; Integer)
        {
            Caption = 'Printer Paper Height';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(pk;
        ID)
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
