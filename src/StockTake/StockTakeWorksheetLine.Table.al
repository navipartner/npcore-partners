table 6014664 "NPR Stock-Take Worksheet Line"
{
    // NPR4.16/TS/20150518  CASE 213313 Created Table
    // NPR4.16/TSA/20150715 CASE 213313 Dimensions handling adopted to sets, added field 480 Dimension Set Id, validate of shortcut dims
    // NPR4.16/TSA/20150917 CASE 222486 Original Primary Key SQL Datatype of Variant was retained on previsous table definition, changed to default
    // NPR4.21/TSA/20160107 CASE 231081 - Stock Take duplicate items in inv jnl, flowfield "Qty. (Total Counted)" to exclude "Worksheet Name"
    // NPR5.30/TS  /20170207 CASE 265349 Corrected CalcFormula for Variant Description
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 82
    // /RA  /20190617 CASE 355055 Added field 500
    // NPR5.51/JAKUBV/20190903  CASE 355055 Transport NPR5.51 - 3 September 2019

    Caption = 'Statement Line';
    DrillDownPageID = "NPR StockTake Worksh. Line";
    LookupPageID = "NPR StockTake Worksh. Line";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Stock-Take Config Code"; Code[10])
        {
            Caption = 'Stock-Take Conf. Code';
            TableRelation = "NPR Stock-Take Configuration".Code;
            DataClassification = CustomerContent;
        }
        field(2; "Worksheet Name"; Code[10])
        {
            Caption = 'Worksheet Name';
            TableRelation = "NPR Stock-Take Worksheet".Name WHERE("Stock-Take Config Code" = FIELD("Stock-Take Config Code"));
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Barcode; Text[30])
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                StockTakeMgr.TranslateBarcode(Rec);
                StockTakeMgr.AssignItemCost(Rec);
            end;
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                Validate("Variant Code", '');
                Validate("Item Translation Source", 0);

                //-NPR5.51
                if Item.Get("Item No.") then begin
                    "Item Tracking Code" := Item."Item Tracking Code";
                end;
                //+NPR5.51

                StockTakeMgr.AssignItemCost(Rec);
            end;
        }
        field(12; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Item Translation Source", 0);
            end;
        }
        field(13; "Qty. (Counted)"; Decimal)
        {
            Caption = 'Qty. (Counted)';
            DataClassification = CustomerContent;
        }
        field(14; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                StockTakeConfig.Get("Stock-Take Config Code");
                StockTakeConfig.TestField("Allow Unit Cost Change", true);
            end;
        }
        field(15; "Date of Inventory"; Date)
        {
            Caption = 'Date of Inventory';
            DataClassification = CustomerContent;
        }
        field(16; Blocked; Boolean)
        {
            CalcFormula = Lookup (Item.Blocked WHERE("No." = FIELD("Item No.")));
            Caption = 'Blocked';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Require Variant Code"; Boolean)
        {
            CalcFormula = Exist ("Item Variant" WHERE("Item No." = FIELD("Item No.")));
            Caption = 'Require Variant Code';
            FieldClass = FlowField;
        }
        field(20; "Shelf  No."; Code[10])
        {
            Caption = 'Shelf  No.';
            DataClassification = CustomerContent;
        }
        field(34; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                StockTakeMgr.ValidateShortcutDimCode(Rec, 1, "Shortcut Dimension 1 Code", "Dimension Set ID");
            end;
        }
        field(35; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                StockTakeMgr.ValidateShortcutDimCode(Rec, 2, "Shortcut Dimension 2 Code", "Dimension Set ID");
            end;
        }
        field(50; "Item Translation Source"; Integer)
        {
            Caption = 'Item Translation Source';
            DataClassification = CustomerContent;
        }
        field(60; "Session ID"; Guid)
        {
            Caption = 'Session ID';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(61; "Session Name"; Text[30])
        {
            Caption = 'Session Name';
            DataClassification = CustomerContent;
        }
        field(62; "Session DateTime"; DateTime)
        {
            Caption = 'Session DateTime';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(63; "Transfer State"; Option)
        {
            Caption = 'Transfer Option';
            OptionCaption = 'Ready,Ignore,Transferred';
            OptionMembers = READY,IGNORE,TRANSFERRED;
            DataClassification = CustomerContent;
        }
        field(80; "Item Description"; Text[50])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(81; "Variant Description"; Text[50])
        {
            CalcFormula = Lookup ("Item Variant".Description WHERE(Code = FIELD("Variant Code"),
                                                                   "Item No." = FIELD("Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(82; "Item Trans. Source Desc."; Text[50])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Item Translation Source")));
            Caption = 'Item Trans. Source Desc.';
            Editable = false;
            FieldClass = FlowField;
            InitValue = 'Invalid Barcode';
        }
        field(300; "Qty. (Total Counted)"; Decimal)
        {
            CalcFormula = Sum ("NPR Stock-Take Worksheet Line"."Qty. (Counted)" WHERE("Stock-Take Config Code" = FIELD("Stock-Take Config Code"),
                                                                                  "Item No." = FIELD("Item No."),
                                                                                  "Variant Code" = FIELD("Variant Code")));
            Caption = 'Qty. (Total Counted)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(310; "Phys. Inv. Batch Name Filter"; Code[20])
        {
            Caption = 'Phys. Inv. Batch Name Filter';
            FieldClass = FlowFilter;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                ShowDimensions;
            end;
        }
        field(500; "Item Tracking Code"; Code[10])
        {
            Caption = 'Item Tracking Code';
            Editable = false;
            TableRelation = "Item Tracking Code";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Stock-Take Config Code", "Worksheet Name", "Line No.")
        {
        }
        key(Key2; "Stock-Take Config Code", "Worksheet Name", "Item No.", "Variant Code")
        {
            SumIndexFields = "Qty. (Counted)";
        }
        key(Key3; "Item No.", "Variant Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
    end;

    trigger OnInsert()
    begin
        TestField("Stock-Take Config Code");
        TestField("Worksheet Name");

        StockTakeWorksheet.Get("Stock-Take Config Code", "Worksheet Name");
        StockTakeMgr.ImportPreHandler(StockTakeWorksheet);

        "Session DateTime" := CurrentDateTime();
        "Session ID" := CreateGuid();

        StockTakeMgr.CreateDefaultDim(Rec);
    end;

    trigger OnModify()
    begin
        TestField("Stock-Take Config Code");
        TestField("Worksheet Name");

        "Session DateTime" := CurrentDateTime();
        StockTakeMgr.CreateDefaultDim(Rec);
    end;

    trigger OnRename()
    begin
        TestField("Stock-Take Config Code");
        TestField("Worksheet Name");
    end;

    var
        StockTakeMgr: Codeunit "NPR Stock-Take Manager";
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        StockTakeConfig: Record "NPR Stock-Take Configuration";
        DimMgt: Codeunit DimensionManagement;

    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2 %3', "Stock-Take Config Code", "Worksheet Name", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        Modify();
    end;
}

