table 6060003 "NPR RS Posted Nivelation Hdr"
{
    Caption = 'Posted Nivelation Document';
    DataClassification = CustomerContent;
    Access = Internal;
    DrillDownPageId = "NPR RS Posted Nivelation Doc";
    LookupPageId = "NPR RS Posted Nivelation Doc";

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
                    NoSeriesMgt.TestManual(LocalizationSetup."RS Posted Niv. No. Series");
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
            DataClassification = CustomerContent;
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
        field(15; "Source Type"; Enum "NPR RS Nivelation Source Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Source Type';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Key1; "Posting Date")
        {
        }
    }

    trigger OnInsert()
    var
    begin
        if "No." = '' then begin
            LocalizationSetup.Get();
            LocalizationSetup.TestField("RS Posted Niv. No. Series");
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            "No. Series" := LocalizationSetup."RS Posted Niv. No. Series";
            if NoSeriesMgt.AreRelated(LocalizationSetup."RS Posted Niv. No. Series", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := NoSeriesMgt.GetNextNo("No. Series");
#ELSE
            NoSeriesMgt.InitSeries(LocalizationSetup."RS Posted Niv. No. Series", xRec."No. Series", 0D, "No.", "No. Series");
#ENDIF
        end;
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Posting Date", "No.");
        NavigatePage.Run();
    end;

    var
        LocalizationSetup: Record "NPR RS R Localization Setup";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
}