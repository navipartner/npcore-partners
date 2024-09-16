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
            trigger OnValidate()
            begin
                if Type in ["NPR RS Nivelation Type"::"Price Change"] then
                    "Source Type" := "NPR RS Nivelation Source Type"::"Sales Price List";
            end;
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("NPR Retail Location" = const(true));
            trigger OnValidate()
            var
                Location: Record Location;
            begin
                if Location.Get("Location Code") then
                    "Location Name" := Location.Name;
                SetLocationCodeOnNivelationLines();
            end;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                SetPostingDateOnNivelationLines();
            end;
        }
        field(5; "Price List Code"; Code[20])
        {
            TableRelation = "Price List Header" where("NPR Location Code" = field("Location Code"));
            Caption = 'Price List Code';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                SetPriceValidDate();
                SetOldPriceOnNivelationLines();
            end;
        }
        field(7; "Location Name"; Text[100])
        {
            Caption = 'Location Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; Amount; Decimal)
        {
            Caption = 'Amount';
            FieldClass = FlowField;
            CalcFormula = Sum("NPR RS Nivelation Lines"."Value Difference" where("Document No." = field("No.")));
            Editable = false;
        }
        field(9; "Price Valid Date"; Date)
        {
            Caption = 'Price Valid Date';
            DataClassification = CustomerContent;
            Editable = false;
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
            Editable = false;
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
            trigger OnValidate()
            begin
                ValidateSourceType();
            end;
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

    local procedure ValidateSourceType()
    var
        PriceChangeSourceTypeNotValidErr: Label 'You cannot choose %1 %2 for %3 %4', Comment = '%1 = Source Type Field Caption, %2 = Source Type, %3 = Type Field Caption, %4 = Type';
    begin
        if (Type in ["NPR RS Nivelation Type"::"Price Change"]) and ("Source Type" in ["NPR RS Nivelation Source Type"::"Sales Price List"]) then
            exit;
        if (Type in ["NPR RS Nivelation Type"::"Promotions & Discounts"]) and not ("Source Type" in ["NPR RS Nivelation Source Type"::"Sales Price List"]) then
            exit;

        Error(PriceChangeSourceTypeNotValidErr, FieldCaption("Source Type"), "Source Type", FieldCaption(Type), Type);
    end;

    local procedure SetPostingDateOnNivelationLines()
    var
        NivelationLines: Record "NPR RS Nivelation Lines";
    begin
        NivelationLines.SetRange("Document No.", Rec."No.");
        if not NivelationLines.FindSet(true) then
            exit;

        repeat
            if NivelationLines."Posting Date" <> Rec."Posting Date" then begin
                NivelationLines.Validate("Posting Date", Rec."Posting Date");
                NivelationLines.Modify();
            end;
        until NivelationLines.Next() = 0;
    end;

    local procedure SetLocationCodeOnNivelationLines()
    var
        NivelationLines: Record "NPR RS Nivelation Lines";
    begin
        NivelationLines.SetRange("Document No.", Rec."No.");
        if not NivelationLines.FindSet(true) then
            exit;

        repeat
            if NivelationLines."Location Code" <> Rec."Location Code" then begin
                NivelationLines.Validate("Location Code", Rec."Location Code");
                NivelationLines.Modify();
            end;
        until NivelationLines.Next() = 0;
    end;

    local procedure SetOldPriceOnNivelationLines()
    var
        NivelationLines: Record "NPR RS Nivelation Lines";
    begin
        NivelationLines.SetRange("Document No.", Rec."No.");
        if not NivelationLines.FindSet(true) then
            exit;

        repeat
            SetPriceListUnitPrice(NivelationLines);
        until NivelationLines.Next() = 0;
    end;

    local procedure SetPriceValidDate()
    var
        PriceListHeader: Record "Price List Header";
    begin
        if not PriceListHeader.Get(Rec."Price List Code") then
            exit;
        Rec."Price Valid Date" := PriceListHeader."Starting Date";
        Rec."Referring Document Code" := PriceListHeader.Code;
    end;

    local procedure SetPriceListUnitPrice(var NivelationLine: Record "NPR RS Nivelation Lines")
    var
        PriceListLine: Record "Price List Line";
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
    begin
        PriceListLine.SetRange("Price List Code", "Price List Code");
        PriceListLine.SetRange("Asset No.", NivelationLine."Item No.");
        PriceListLine.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, "Price Valid Date"));
        PriceListLine.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, "Price Valid Date"));
        if not PriceListLine.FindFirst() then
            NivelationLine.Validate("Old Price", 0)
        else
            NivelationLine.Validate("Old Price", PriceListLine."Unit Price");
        NivelationLine.Modify();
    end;

    var
        LocalizationSetup: Record "NPR RS R Localization Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}