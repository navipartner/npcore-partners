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
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
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
                    Error(DimMgt.GetDimErr());
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
                    Error(DimMgt.GetDimErr());
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

    trigger OnDelete()
    begin
        GLSetup.Get();
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

        GLSetup.Get();

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
        GLSetup.Get();
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
        Ekspedition: Record "NPR POS Sale";
        Ekspeditionlinie: Record "NPR POS Sale Line";
    begin
        case "Table ID" of
            DATABASE::"NPR POS Sale":
                begin
                    Ekspedition.SetRange("Register No.", Kassenr);
                    Ekspedition.SetRange("Sales Ticket No.", Bonnr);
                    if Ekspedition.FindFirst() then begin
                        case GlobalDimCodeNo of
                            1:
                                Ekspedition."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                Ekspedition."Shortcut Dimension 2 Code" := NewDimValue;
                        end;
                        Ekspedition.Modify(true);
                    end;
                end;
            DATABASE::"NPR POS Sale Line":
                begin
                    if Ekspeditionlinie.Get(Kassenr, Bonnr, Dato2, EkspArt, LinjeNr) then begin
                        case GlobalDimCodeNo of
                            1:
                                Ekspeditionlinie."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                Ekspeditionlinie."Shortcut Dimension 2 Code" := NewDimValue;
                        end;
                        Ekspeditionlinie.Modify(false);
                    end;
                end;
        end;
    end;
    #region UpdateLineDim
    procedure UpdateLineDim(var NPRLineDim: Record "NPR Line Dimension"; FromOnDelete: Boolean)
    var
        NewNPRLineDim: Record "NPR Line Dimension";
        "Ekspedition linie": Record "NPR POS Sale Line";
    begin
        if (NPRLineDim."Table ID" = DATABASE::"NPR POS Sale") then begin
            NewNPRLineDim.SetRange("Table ID", DATABASE::"NPR POS Sale Line");
            NewNPRLineDim.SetRange("Register No.", NPRLineDim."Register No.");
            NewNPRLineDim.SetRange("Sales Ticket No.", NPRLineDim."Sales Ticket No.");
            NewNPRLineDim.SetRange("Sale Type", NPRLineDim."Sale Type");
            NewNPRLineDim.SetRange("Line No.", NPRLineDim."Line No.");
            NewNPRLineDim.SetRange(Date, NPRLineDim.Date);
            NewNPRLineDim.SetRange("Dimension Code", NPRLineDim."Dimension Code");
            if FromOnDelete then
                if not NewNPRLineDim.FindFirst() then
                    exit;
            "Ekspedition linie".SetRange("Register No.", NPRLineDim."Register No.");
            "Ekspedition linie".SetRange("Sales Ticket No.", NPRLineDim."Sales Ticket No.");
            if "Ekspedition linie".FindSet() then begin
                NewNPRLineDim.DeleteAll(true);
                if not FromOnDelete then
                    repeat
                        InsertNew(
                          NPRLineDim, DATABASE::"NPR POS Sale Line", "Ekspedition linie");
                    until "Ekspedition linie".Next() = 0;
            end;
        end;
    end;
    #endregion
    #region InsertNew
    local procedure InsertNew(var NPRLineDim: Record "NPR Line Dimension"; TableNo: Integer; var "Ekspedition linie": Record "NPR POS Sale Line")
    var
        NewNPRLineDim: Record "NPR Line Dimension";
    begin
        NewNPRLineDim."Table ID" := TableNo;
        NewNPRLineDim."Register No." := "Ekspedition linie"."Register No.";
        NewNPRLineDim."Sales Ticket No." := "Ekspedition linie"."Sales Ticket No.";
        NewNPRLineDim."Sale Type" := "Ekspedition linie"."Sale Type";
        NewNPRLineDim."Line No." := "Ekspedition linie"."Line No.";
        NewNPRLineDim.Date := "Ekspedition linie".Date;
        NewNPRLineDim."Dimension Code" := NPRLineDim."Dimension Code";
        NewNPRLineDim."Dimension Value Code" := NPRLineDim."Dimension Value Code";
        if not NewNPRLineDim.Insert(true) then
            if NewNPRLineDim.Modify(true) then;
    end;
    #endregion
    #region GetDimensions
    procedure GetDimensions(TableNo: Integer; Kassenr: Code[10]; Bonnr: Code[20]; EkspArt: Option; Dato2: Date; LinjeNr: Integer; Nr: Code[20]; var TempNPRLineDim: Record "NPR Line Dimension")
    var
        NPRLineDim: Record "NPR Line Dimension";
    begin
        TempNPRLineDim.DeleteAll();

        NPRLineDim.Reset();
        NPRLineDim.SetRange("Table ID", TableNo);
        NPRLineDim.SetRange("Register No.", Kassenr);
        NPRLineDim.SetRange("Sales Ticket No.", Bonnr);
        NPRLineDim.SetRange("Sale Type", EkspArt);
        NPRLineDim.SetRange("Line No.", LinjeNr);
        NPRLineDim.SetRange(Date, Dato2);
        NPRLineDim.SetRange("No.", Nr);
        if NPRLineDim.FindSet() then
            repeat
                TempNPRLineDim := NPRLineDim;
                TempNPRLineDim.Insert();
            until NPRLineDim.Next() = 0;
    end;
    #endregion
    #region UpdateAllLineDim
    procedure UpdateAllLineDim(TableNo: Integer; Kassenr: Code[10]; Bonnr: Code[20]; EkspArt: Option; Dato2: Date; var OldNPRLineDimHeader: Record "NPR Line Dimension")
    var
        NPRLineDimHeader: Record "NPR Line Dimension";
        NPRLineDimLine: Record "NPR Line Dimension";
        Ekspeditionlinie: Record "NPR POS Sale Line";
        LineTableNo: Integer;
    begin
        case TableNo of
            DATABASE::"NPR POS Sale":
                LineTableNo := DATABASE::"NPR POS Sale Line";
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

        if not NPRLineDimLine.FindFirst() then
            exit;

        // Genneml�b alle dimensionerne p� "Ekspedition" EFTER dim er blevet opdateret.
        if NPRLineDimHeader.FindSet() then
            repeat
                if (not OldNPRLineDimHeader.Get(NPRLineDimHeader."Table ID", NPRLineDimHeader."Register No.", NPRLineDimHeader."Sales Ticket No.", NPRLineDimHeader.Date, NPRLineDimHeader."Sale Type", NPRLineDimHeader."Line No.", '', NPRLineDimHeader."Dimension Code"
          )) or
                  (OldNPRLineDimHeader."Dimension Value Code" <> NPRLineDimHeader."Dimension Value Code")
                then begin
                    NPRLineDimLine.SetRange("Dimension Code", NPRLineDimHeader."Dimension Code");
                    NPRLineDimLine.DeleteAll();
                    case TableNo of
                        DATABASE::"NPR POS Sale":
                            begin
                                Ekspeditionlinie.SetRange("Register No.", Kassenr);
                                Ekspeditionlinie.SetRange("Sales Ticket No.", Bonnr);
                                if Ekspeditionlinie.FindSet() then
                                    repeat
                                        InsertNew(NPRLineDimHeader, LineTableNo, Ekspeditionlinie);
                                    until Ekspeditionlinie.Next() = 0;
                            end;
                    end;
                end;
            until NPRLineDimHeader.Next() = 0;

        // Genneml�b alle dimensionerne p� "Ekspedition" F�R dim er blevet opdateret.
        // hvis Dimensionskoden vare der f�r men ikke mere, s� slettes Dimensionslinjerne med denne Dimensionskode
        if OldNPRLineDimHeader.FindSet() then
            repeat
                if not NPRLineDimHeader.Get(OldNPRLineDimHeader."Table ID", Kassenr, Bonnr, Dato2, EkspArt, OldNPRLineDimHeader."Line No.", '', OldNPRLineDimHeader."Dimension Code") then begin
                    NPRLineDimLine.SetRange("Dimension Code", OldNPRLineDimHeader."Dimension Code");
                    NPRLineDimLine.DeleteAll();
                end;
            until OldNPRLineDimHeader.Next() = 0;
    end;
    #endregion
}

