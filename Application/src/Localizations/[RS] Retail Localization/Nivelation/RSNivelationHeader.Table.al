table 6059998 "NPR RS Nivelation Header"
{
    Caption = 'Nivelation Document';
    DataClassification = CustomerContent;
    Access = Internal;
    DrillDownPageId = "NPR RS Nivelation Header";
    LookupPageId = "NPR RS Nivelation Header";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    LocalizationSetup.Get();
                    NoSeriesMgt.TestManual(LocalizationSetup."RS Nivelation Hdr No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Type; Enum "NPR RS Nivelation Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(3; "Location Code"; Code[10])
        {
            TableRelation = Location.Code;
            Caption = 'Location Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Location: Record Location;
            begin
                if Location.Get("Location Code") then
                    "Location Name" := Location.Name;
            end;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(5; "Price List Code"; Code[20])
        {
            TableRelation = "Price List Header" where("NPR Location Code" = field("Location Code"));
            Caption = 'Price List Code';
            DataClassification = CustomerContent;
        }
        field(7; "Location Name"; Text[100])
        {
            Caption = 'Location Name';
            DataClassification = CustomerContent;
        }
        field(8; Amount; Decimal)
        {
            Caption = 'Amount';
            FieldClass = FlowField;
            CalcFormula = Sum("NPR RS Nivelation Lines"."Value Difference" where("Document No." = field("No.")));
        }
        field(9; "Price Valid Date"; Date)
        {
            Caption = 'Price Valid Date';
            DataClassification = CustomerContent;
        }
        field(10; "No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No. Series';
        }
        field(12; Status; Enum "NPR RS Nivelation Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            InitValue = Unposted;
        }
        field(13; "Referring Document Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Referring Document Code';
        }
        field(14; "Last Posting No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Posting No.';
        }
    }

    keys
    {
        key(PK; Type, "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
    begin
        if "No." <> '' then
            exit;
        LocalizationSetup.Get();
        LocalizationSetup.TestField("RS Nivelation Hdr No. Series");
        NoSeriesMgt.InitSeries(LocalizationSetup."RS Nivelation Hdr No. Series", xRec."No. Series", 0D, "No.", "No. Series");
    end;

    var
        LocalizationSetup: Record "NPR RS R Localization Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}