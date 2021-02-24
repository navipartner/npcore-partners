table 6014430 "NPR Line Dimension"
{
    Caption = 'NPR Line Dimension';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
            DataClassification = CustomerContent;
        }
        field(2; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            NotBlank = true;
            TableRelation = "NPR POS Unit";
            DataClassification = CustomerContent;
        }
        field(3; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(4; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Payment1,Disbursement,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Payment1,Disbursement,Comment,Cancelled,"Open/Close";
            DataClassification = CustomerContent;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(6; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(7; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(10; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            NotBlank = true;
            TableRelation = Dimension;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not DimMgt.CheckDim("Dimension Code") then
                    Error(DimMgt.GetDimErr);
            end;
        }
        field(11; "Dimension Value Code"; Code[20])
        {
            Caption = 'Dimension Value Code';
            NotBlank = true;
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FIELD("Dimension Code"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not DimMgt.CheckDimValue("Dimension Code", "Dimension Value Code") then
                    Error(DimMgt.GetDimErr);
            end;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Register No.", "Sales Ticket No.", Date, "Sale Type", "Line No.", "No.", "Dimension Code")
        {
        }
        key(Key2; "Table ID", Date, "Sale Type", "Line No.", "Dimension Code", "Dimension Value Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        GLSetup.Get;
        UpdateLineDim(Rec, true);

        if "Dimension Code" = GLSetup."Global Dimension 1 Code" then
            UpdateGlobalDimCode(
              1,
              "Table ID",
              "Register No.",
              "Sales Ticket No.",
              Date,
              "Sale Type",
              "Line No.",
              "No.",
              '');

        if "Dimension Code" = GLSetup."Global Dimension 2 Code" then
            UpdateGlobalDimCode(
              2,
              "Table ID",
              "Register No.",
              "Sales Ticket No.",
              Date,
              "Sale Type",
              "Line No.",
              "No.",
              '');
    end;

    trigger OnInsert()
    begin
        TestField("Dimension Value Code");

        GLSetup.Get;

        UpdateLineDim(Rec, false);

        if "Dimension Code" = GLSetup."Global Dimension 1 Code" then
            UpdateGlobalDimCode(
              1,
              "Table ID",
              "Register No.",
              "Sales Ticket No.",
              Date,
              "Sale Type",
              "Line No.",
              "No.",
              "Dimension Value Code");

        if "Dimension Code" = GLSetup."Global Dimension 2 Code" then
            UpdateGlobalDimCode(
              2,
              "Table ID",
              "Register No.",
              "Sales Ticket No.",
              Date,
              "Sale Type",
              "Line No.",
              "No.",
              "Dimension Value Code");
    end;

    trigger OnModify()
    begin
        GLSetup.Get;
        UpdateLineDim(Rec, false);

        if "Dimension Code" = GLSetup."Global Dimension 1 Code" then
            UpdateGlobalDimCode(
              1,
              "Table ID",
              "Register No.",
              "Sales Ticket No.",
              Date,
              "Sale Type",
              "Line No.",
              "No.",
              "Dimension Value Code");

        if "Dimension Code" = GLSetup."Global Dimension 2 Code" then
            UpdateGlobalDimCode(
              2,
              "Table ID",
              "Register No.",
              "Sales Ticket No.",
              Date,
              "Sale Type",
              "Line No.",
              "No.",
              "Dimension Value Code");
    end;

    trigger OnRename()
    begin
        Error(Text000, TableCaption);
    end;

    var
        Text000: Label 'You can not rename a %1.';
        GLSetup: Record "General Ledger Setup";
        DimMgt: Codeunit DimensionManagement;

    procedure UpdateGlobalDimCode(GlobalDimCodeNo: Integer; "Table ID": Integer; Kassenr: Code[10]; Bonnr: Code[20]; Dato2: Date; EkspArt: Option; LinjeNr: Integer; Nr: Code[20]; NewDimValue: Code[20])
    var
        Ekspedition: Record "NPR Sale POS";
        Ekspeditionlinie: Record "NPR Sale Line POS";
        Revisionsrulle: Record "NPR Audit Roll";
    begin
        //UpdateGlobalDimCode

        case "Table ID" of
            DATABASE::"NPR Sale POS":
                begin
                    Ekspedition.SetRange("Register No.", Kassenr);
                    Ekspedition.SetRange("Sales Ticket No.", Bonnr);
                    //IF Ekspedition.GET(Kassenr,Bonnr) THEN BEGIN
                    if Ekspedition.Find('-') then begin
                        case GlobalDimCodeNo of
                            1:
                                Ekspedition."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                Ekspedition."Shortcut Dimension 2 Code" := NewDimValue;
                        end;
                        Ekspedition.Modify(true);
                    end;
                end;
            DATABASE::"NPR Sale Line POS":
                begin
                    if Ekspeditionlinie.Get(Kassenr, Bonnr, Dato2, EkspArt, LinjeNr) then begin
                        case GlobalDimCodeNo of
                            1:
                                Ekspeditionlinie."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                Ekspeditionlinie."Shortcut Dimension 2 Code" := NewDimValue;
                        end;
                        Ekspeditionlinie.Modify(false);
                        //Ekspeditionlinie.MODIFY(TRUE);  //Henrik Ohm, 10/6/2005 - Failure due to terminal approved
                    end;
                end;
            DATABASE::"NPR Audit Roll":
                begin
                    if Revisionsrulle.Get(Kassenr, Bonnr, EkspArt, LinjeNr, Nr, Dato2) then begin
                        case GlobalDimCodeNo of
                            1:
                                Revisionsrulle."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                Revisionsrulle."Shortcut Dimension 2 Code" := NewDimValue;
                        end;
                        Revisionsrulle.Modify(true);
                    end;
                end;
        end;
    end;

    procedure UpdateLineDim(var NPRLineDim: Record "NPR Line Dimension"; FromOnDelete: Boolean)
    var
        NewNPRLineDim: Record "NPR Line Dimension";
        "Ekspedition linie": Record "NPR Sale Line POS";
    begin
        //UpdateLineDim

        with NPRLineDim do begin
            if ("Table ID" = DATABASE::"NPR Sale POS") then begin
                NewNPRLineDim.SetRange("Table ID", DATABASE::"NPR Sale Line POS");
                NewNPRLineDim.SetRange("Register No.", "Register No.");
                NewNPRLineDim.SetRange("Sales Ticket No.", "Sales Ticket No.");
                NewNPRLineDim.SetRange("Sale Type", "Sale Type");
                NewNPRLineDim.SetRange("Line No.", "Line No.");
                NewNPRLineDim.SetRange(Date, Date);
                NewNPRLineDim.SetRange("Dimension Code", "Dimension Code");
                if FromOnDelete then
                    if not NewNPRLineDim.Find('-') then
                        exit;
                "Ekspedition linie".SetRange("Register No.", "Register No.");
                "Ekspedition linie".SetRange("Sales Ticket No.", "Sales Ticket No.");
                if "Ekspedition linie".Find('-') then begin
                    NewNPRLineDim.DeleteAll(true);
                    if not FromOnDelete then
                        repeat
                            InsertNew(
                              NPRLineDim, DATABASE::"NPR Sale Line POS", "Ekspedition linie");
                        until "Ekspedition linie".Next = 0;
                end;
            end;
        end;
    end;

    local procedure InsertNew(var NPRLineDim: Record "NPR Line Dimension"; TableNo: Integer; var "Ekspedition linie": Record "NPR Sale Line POS")
    var
        NewNPRLineDim: Record "NPR Line Dimension";
    begin
        //InsertNew

        with NPRLineDim do begin
            NewNPRLineDim."Table ID" := TableNo;
            NewNPRLineDim."Register No." := "Ekspedition linie"."Register No.";
            NewNPRLineDim."Sales Ticket No." := "Ekspedition linie"."Sales Ticket No.";
            NewNPRLineDim."Sale Type" := "Ekspedition linie"."Sale Type";
            NewNPRLineDim."Line No." := "Ekspedition linie"."Line No.";
            NewNPRLineDim.Date := "Ekspedition linie".Date;
            NewNPRLineDim."Dimension Code" := "Dimension Code";
            NewNPRLineDim."Dimension Value Code" := "Dimension Value Code";
            if not NewNPRLineDim.Insert(true) then
                if NewNPRLineDim.Modify(true) then;
        end;
    end;

    procedure GetDimensions(TableNo: Integer; Kassenr: Code[10]; Bonnr: Code[20]; EkspArt: Option; Dato2: Date; LinjeNr: Integer; Nr: Code[20]; var TempNPRLineDim: Record "NPR Line Dimension")
    var
        NPRLineDim: Record "NPR Line Dimension";
    begin
        //GetDimensions
        TempNPRLineDim.DeleteAll;

        with NPRLineDim do begin
            Reset;
            SetRange("Table ID", TableNo);
            SetRange("Register No.", Kassenr);
            SetRange("Sales Ticket No.", Bonnr);
            SetRange("Sale Type", EkspArt);
            SetRange("Line No.", LinjeNr);
            SetRange(Date, Dato2);
            SetRange("No.", Nr);
            if Find('-') then
                repeat
                    TempNPRLineDim := NPRLineDim;
                    TempNPRLineDim.Insert;
                until Next = 0;
        end;
    end;

    procedure UpdateAllLineDim(TableNo: Integer; Kassenr: Code[10]; Bonnr: Code[20]; EkspArt: Option; Dato2: Date; var OldNPRLineDimHeader: Record "NPR Line Dimension")
    var
        NPRLineDimHeader: Record "NPR Line Dimension";
        NPRLineDimLine: Record "NPR Line Dimension";
        Ekspeditionlinie: Record "NPR Sale Line POS";
        LineTableNo: Integer;
    begin
        //UpdateAllLineDim
        case TableNo of
            DATABASE::"NPR Sale POS":
                LineTableNo := DATABASE::"NPR Sale Line POS";
        end;

        NPRLineDimHeader.SetRange("Table ID", TableNo);
        NPRLineDimHeader.SetRange("Register No.", Kassenr);
        NPRLineDimHeader.SetRange("Sales Ticket No.", Bonnr);
        NPRLineDimHeader.SetRange("Sale Type", 0);
        NPRLineDimHeader.SetRange(Date, 0D);
        NPRLineDimHeader.SetRange("Line No.", 0);
        NPRLineDimHeader.SetRange("No.", '');

        NPRLineDimLine.SetRange("Table ID", LineTableNo);
        NPRLineDimLine.SetRange("Register No.", Kassenr);
        NPRLineDimLine.SetRange("Sales Ticket No.", Bonnr);
        NPRLineDimLine.SetFilter("Line No.", '<> 0');
        NPRLineDimLine.SetRange("No.", '');

        if not NPRLineDimLine.Find('-') then
            exit;

        // Genneml¢b alle dimensionerne på "Ekspedition" EFTER dim er blevet opdateret.
        with NPRLineDimHeader do
            if Find('-') then
                repeat
                    if (not OldNPRLineDimHeader.Get("Table ID", "Register No.", "Sales Ticket No.", Date, "Sale Type", "Line No.", '', "Dimension Code"
              )) or
                      (OldNPRLineDimHeader."Dimension Value Code" <> "Dimension Value Code")
                    then begin
                        NPRLineDimLine.SetRange("Dimension Code", "Dimension Code");
                        NPRLineDimLine.DeleteAll;
                        case TableNo of
                            DATABASE::"NPR Sale POS":
                                begin
                                    Ekspeditionlinie.SetRange("Register No.", Kassenr);
                                    Ekspeditionlinie.SetRange("Sales Ticket No.", Bonnr);
                                    if Ekspeditionlinie.Find('-') then
                                        repeat
                                            InsertNew(NPRLineDimHeader, LineTableNo, Ekspeditionlinie);
                                        until Ekspeditionlinie.Next = 0;
                                end;
                        end;
                    end;
                until Next = 0;

        // Genneml¢b alle dimensionerne på "Ekspedition" F¥R dim er blevet opdateret.
        // hvis Dimensionskoden vare der f¢r men ikke mere, så slettes Dimensionslinjerne med denne Dimensionskode
        with OldNPRLineDimHeader do
            if Find('-') then
                repeat
                    if not NPRLineDimHeader.Get("Table ID", Kassenr, Bonnr, Dato2, EkspArt, "Line No.", '', "Dimension Code") then begin
                        NPRLineDimLine.SetRange("Dimension Code", "Dimension Code");
                        NPRLineDimLine.DeleteAll;
                    end;
                until Next = 0;
    end;
}

