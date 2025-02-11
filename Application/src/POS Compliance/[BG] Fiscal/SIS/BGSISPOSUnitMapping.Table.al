table 6060097 "NPR BG SIS POS Unit Mapping"
{
    Access = Internal;
    Caption = 'BG SIS POS Unit Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR BG SIS POS Unit Mapping";
    LookupPageId = "NPR BG SIS POS Unit Mapping";

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(5; "POS Unit Name"; Text[50])
        {
            CalcFormula = lookup("NPR POS Unit".Name where("No." = field("POS Unit No.")));
            Caption = 'POS Unit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Fiscal Printer IP Address"; Text[30])
        {
            Caption = 'Fiscal Printer IP Address';
            DataClassification = CustomerContent;
            CharAllowed = '09::..';

            trigger OnValidate()
            begin
                if "Fiscal Printer IP Address" <> xRec."Fiscal Printer IP Address" then begin
                    Clear("Fiscal Printer Device No.");
                    Clear("Fiscal Printer Memory No.");
                    "Printer Model" := "Printer Model"::" ";
                end;
            end;
        }
        field(25; "Printer Model"; Enum "NPR BG SIS Printer Model")
        {
            Caption = 'Printer Model';
            DataClassification = CustomerContent;
        }
        field(30; "Fiscal Printer Device No."; Text[8])
        {
            Caption = 'Fiscal Printer Device No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Fiscal Printer Device No." <> xRec."Fiscal Printer Device No." then
                    Clear("Fiscal Printer Memory No.");
            end;
        }
        field(31; "Fiscal Printer Memory No."; Text[8])
        {
            Caption = 'Fiscal Printer Memory No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(32; "Fiscal Printer Info Refreshed"; DateTime)
        {
            Caption = 'Fiscal Printer Info Refreshed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Extended Receipt Invoice No."; Code[20])
        {
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(51; "Extended Receipt Cr. Memo No."; Code[20])
        {
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Unit No.")
        {
            Clustered = true;
        }
    }

    internal procedure ShouldRefreshFiscalPrinterInfo() ShouldRefresh: Boolean
    begin
        ShouldRefresh := true;
        if ("Fiscal Printer Device No." <> '') and ("Fiscal Printer Memory No." <> '') and ("Fiscal Printer Info Refreshed" <> 0DT) then
            ShouldRefresh := DT2Date("Fiscal Printer Info Refreshed") < Today(); // refresh should happen only when the date is changed in case when fiscal printer info is already populated
    end;

    internal procedure CheckIsPrinterModelPopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 POS Unit Mapping.', Comment = '%1 - Printer Model field caption, %2 - POS Unit No. field value';
    begin
        if "Printer Model" = "Printer Model"::" " then
            Error(NotPopulatedErr, FieldCaption("Printer Model"), "POS Unit No.");
    end;
}