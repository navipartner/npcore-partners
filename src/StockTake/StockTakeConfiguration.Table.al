table 6014665 "NPR Stock-Take Configuration"
{
    // NPR4.16/TS/20150518  CASE 213313 Created Table
    // NPR4.16/TSA/20150716 CASE 213313 - Adopted the dimensions for 7
    // NPR4.16/TSA/20150917 CASE 222486 Original Primary Key SQL Datatype of Variant was retained on previsous table definition, changed to default
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.51/TSA /20190722 CASE 359375 Added field 240 "Keep Worksheets"

    Caption = 'Stock-Take Configuration';
    LookupPageID = "NPR Stock-Take Configs";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(11; "Stock-Take Template Code"; Code[10])
        {
            Caption = 'Stock-Take Template Code';
            TableRelation = "NPR Stock-Take Template".Code;

            trigger OnValidate()
            begin
                if (StockTakeTemplate.Get("Stock-Take Template Code")) then begin
                    if ("Stock-Take Template Code" <> xRec.Code) then
                        if not Confirm(Text001, true, "Stock-Take Template Code", Rec.TableCaption, Code) then Error('');

                    TransferFields(StockTakeTemplate, false);
                end;
            end;
        }
        field(12; "Inventory Calc. Date"; Date)
        {
            Caption = 'Stock-Take Calc. Date';
        }
        field(211; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }
        field(212; "Item Group Filter"; Text[200])
        {
            Caption = 'Item Group Filter';
            TableRelation = "NPR Item Group"."No.";
            ValidateTableRelation = false;
        }
        field(213; "Vendor Code Filter"; Text[200])
        {
            Caption = 'Vendor Code Filter';
            TableRelation = Vendor;
            ValidateTableRelation = false;
        }
        field(214; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ValidateTableRelation = true;
        }
        field(215; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ValidateTableRelation = true;
        }
        field(220; "Session Based Loading"; Option)
        {
            Caption = 'Session Based Loading';
            OptionCaption = 'Append,Append Until Transferred,Append Is Not Allowed';
            OptionMembers = APPEND,APPEND_UNTIL_TRANSFERRED,APPEND_NOT_ALLOWED;
        }
        field(221; "Session Based Transfer"; Option)
        {
            Caption = 'Session Based Transfer';
            OptionCaption = 'All Worksheets,Single Worksheet,Selected Lines';
            OptionMembers = ALL_WORKSHEETS,WORKSHEET,SELECTED_LINES;
        }
        field(222; "Aggregation Level"; Option)
        {
            Caption = 'Aggregation Level';
            OptionCaption = 'Scanned Number,Session Name,Native,Consecutive';
            OptionMembers = SCANNED_NUMBER,SESSION,NATIVE,CONSECUTIVE;
        }
        field(223; "Data Release"; Option)
        {
            Caption = 'Data Release';
            OptionCaption = 'Manual,Per Transfer,Final Transfer';
            OptionMembers = MANUAL,ON_TRANSFER,ON_FINAL_TRANSFER;
        }
        field(224; "Transfer Action"; Option)
        {
            Caption = 'Transfer Action';
            OptionCaption = 'Transfer,Transfer and Post,Transfer Post and Print';
            OptionMembers = TRANSFER,TRANSFER_POST,TRANSFER_POST_PRINT;
        }
        field(225; "Defaul Profile"; Boolean)
        {
            Caption = 'Default Profile';
        }
        field(226; "Allow User Modification"; Boolean)
        {
            Caption = 'Allow User Modification';
        }
        field(227; "Items Out-of-Scope"; Option)
        {
            Caption = 'Items Out-of-Scope';
            OptionCaption = 'Error,Ignore,Accept Count';
            OptionMembers = ERROR,IGNORE,ACCEPT_COUNT;
        }
        field(228; "Items in Scope Not Counted"; Option)
        {
            Caption = 'Items in Scope Not Counted';
            OptionCaption = 'Error,Ignore,Accept Current,Adjust If Negative,Adjust Set Zero';
            OptionMembers = ERROR,IGNORE,ACCEPT_CURRENT,ADJUST_IF_NEGATIVE,ADJUST_SET_ZERO;
        }
        field(229; "Barcode Not Accepted"; Option)
        {
            Caption = 'Barcode Not Accepted';
            OptionCaption = 'Error,Ignore';
            OptionMembers = ERROR,IGNORE;
        }
        field(230; "Counting Method"; Option)
        {
            Caption = 'Counting Method';
            OptionCaption = 'Complete (Non-Zero),Complete,Partial';
            OptionMembers = COMPLETE_NONZERO,COMPLETE_ALL,PARTIAL;
        }
        field(231; "Suggested Unit Cost Source"; Option)
        {
            Caption = 'Suggested Unit Cost Source';
            OptionCaption = 'Unit Cost,Last Direct Cost,Standard Cost';
            OptionMembers = UNIT_COST,LAST_DIRECT_COST,STANDARD_COST;

            trigger OnValidate()
            begin
                if ("Suggested Unit Cost Source" <> xRec."Suggested Unit Cost Source") then begin
                    WorksheetLine.SetRange("Stock-Take Config Code", Code);
                    if (WorksheetLine.FindSet()) then begin
                        if (Confirm(Text002, true, Rec.FieldCaption("Suggested Unit Cost Source"))) then begin
                            repeat
                                StockTakeMgr.AssignItemCost(WorksheetLine);
                                WorksheetLine.Modify();
                            until (WorksheetLine.Next() = 0);
                        end;
                    end;
                end;
            end;
        }
        field(232; "Allow Unit Cost Change"; Boolean)
        {
            Caption = 'Allow Unit Cost Change';
        }
        field(233; "Item Journal Template Name"; Code[10])
        {
            Caption = 'Item Journal Template Name';
            NotBlank = true;
            TableRelation = IF ("Adjustment Method" = CONST(STOCKTAKE)) "Item Journal Template" WHERE(Type = CONST("Phys. Inventory"))
            ELSE
            IF ("Adjustment Method" = CONST(ADJUSTMENT)) "Item Journal Template" WHERE(Type = CONST(Item))
            ELSE
            IF ("Adjustment Method" = CONST(PURCHASE)) "Item Journal Template" WHERE(Type = CONST(Item));

            trigger OnValidate()
            begin
                if ("Item Journal Template Name" <> xRec."Item Journal Template Name") then
                    "Item Journal Batch Name" := '';
            end;
        }
        field(234; "Item Journal Batch Name"; Code[20])
        {
            Caption = 'Item Journal Batch Name';
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD(Code));

            trigger OnLookup()
            begin
                TestField("Item Journal Template Name");
                "Item Journal Batch Name" := StockTakeMgr.SelectItemJournalBatchName("Item Journal Template Name");
            end;
        }
        field(235; "Item Journal Batch Usage"; Option)
        {
            Caption = 'Item Journal Batch Usage';
            OptionCaption = 'Use Directly,As Template';
            OptionMembers = DIRECT,TEMPLATE;
        }
        field(236; "Blocked Item"; Option)
        {
            Caption = 'Blocked Item';
            OptionCaption = 'Error,Ignore,Temporarily Unblock';
            OptionMembers = ERROR,IGNORE,TEMP_UNBLOCK;
        }
        field(237; "Suppress Not Counted"; Boolean)
        {
            Caption = 'Suppress Not Counted';
        }
        field(238; "Stock Take Method"; Option)
        {
            Caption = 'Stock Take Method';
            OptionCaption = 'By Area,By Product,By Dimension';
            OptionMembers = "AREA",PRODUCT,DIMENSION;
        }
        field(239; "Adjustment Method"; Option)
        {
            Caption = 'Adjustment Method';
            OptionCaption = 'Stock-Take,Adjustment,Purchase (Adjmt.)';
            OptionMembers = STOCKTAKE,ADJUSTMENT,PURCHASE;
        }
        field(240; "Keep Worksheets"; Boolean)
        {
            Caption = 'Keep Worksheets';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        StockTakeWorksheet.SetRange("Stock-Take Config Code", Code);
        if (StockTakeWorksheet.FindFirst()) then
            StockTakeWorksheet.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        if Code = '' then
            Error(TextNoCode);

        StockTakeTemplate.SetFilter("Defaul Profile", '=%1', true);
        if (StockTakeTemplate.FindFirst()) then
            TransferFields(StockTakeTemplate, false);
    end;

    trigger OnModify()
    begin
        if Code = '' then
            Error(TextNoCode);
    end;

    var
        StockTakeMgr: Codeunit "NPR Stock-Take Manager";
        ItemJounrnalTemplate: Record "Item Journal Template";
        StockTakeTemplate: Record "NPR Stock-Take Template";
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        WorksheetLine: Record "NPR Stock-Take Worksheet Line";
        TextNoCode: Label 'Please type a Code.';
        Text001: Label 'Do you want to change the current template to %1 for %2 %3';
        Text002: Label 'If you change %1, all lines must be re-evaluated.\\Do you want to continue?';
        DimMgt: Codeunit DimensionManagement;
        PostingDefaultDim1: Code[20];
        PostingDefaultDim2: Code[20];

    procedure OpdaterLinie()
    begin
        //NFCode.TR419OpdaterLinie( Rec );
    end;

    procedure AssistEdit(): Boolean
    var
        this: Record "NPR Stock-Take Worksheet";
    begin
        /*
        WITH this DO BEGIN
          this := Rec;
          Opsætning.GET;
          Opsætning.TESTFIELD("Phys. Inventory Journal Nos.");
          IF Nrseriestyring.SelectSeries(Opsætning."Phys. Inventory Journal Nos.", '',Opsætning."Phys. Inventory Journal Nos.") THEN BEGIN
            Nrseriestyring.SetSeries(Code);
            Rec := this;
            EXIT(TRUE);
          END;
        END;
        */

    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        Modify;
    end;

    procedure AllowModify()
    begin
    end;
}

