table 6014666 "Stock-Take Template"
{
    // NPR4.16/TS/20150518  CASE 213313 Created Table
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.40/TS  /20170331  CASE 307818 Changed ENU Caption

    Caption = 'Stock-Take Template';
    DrillDownPageID = "Stock-Take Templates";
    LookupPageID = "Stock-Take Templates";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(210;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(211;"Location Code";Code[20])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }
        field(212;"Item Group Filter";Text[200])
        {
            Caption = 'Item Group Filter';
            TableRelation = "Item Group"."No.";
            ValidateTableRelation = false;
        }
        field(213;"Vendor Code Filter";Text[200])
        {
            Caption = 'Vendor Code Filter';
            TableRelation = Vendor;
            ValidateTableRelation = false;
        }
        field(214;"Global Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
            ValidateTableRelation = true;
        }
        field(215;"Global Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
            ValidateTableRelation = true;
        }
        field(220;"Session Based Loading";Option)
        {
            Caption = 'Session Based Loading';
            OptionCaption = 'Append,Append Until Transferred,Append Is Not Allowed';
            OptionMembers = APPEND,APPEND_UNTIL_TRANSFERRED,APPEND_NOT_ALLOWED;
        }
        field(221;"Session Based Transfer";Option)
        {
            Caption = 'Session Based Transfer';
            OptionCaption = 'All Worksheets,Single Worksheet,Selected Lines';
            OptionMembers = ALL_WORKSHEETS,WORKSHEET,SELECTED_LINES;
        }
        field(222;"Aggregation Level";Option)
        {
            Caption = 'Aggregation Level';
            OptionCaption = 'Scanned Number,Session Name,Native,Consecutive';
            OptionMembers = SCANNED_NUMBER,SESSION,NATIVE,CONSECUTIVE;
        }
        field(223;"Data Release";Option)
        {
            Caption = 'Data Release';
            OptionCaption = 'Manual,Per Transfer,Final Transfer';
            OptionMembers = MANUAL,ON_TRANSFER,ON_FINAL_TRANSFER;
        }
        field(224;"Transfer Action";Option)
        {
            Caption = 'Transfer Action';
            OptionCaption = 'Transfer,Transfer and Post,Transfer Post and Print';
            OptionMembers = TRANSFER,TRANSFER_POST,TRANSFER_POST_PRINT;
        }
        field(225;"Defaul Profile";Boolean)
        {
            Caption = 'Default Profile';
        }
        field(226;"Allow User Modification";Boolean)
        {
            Caption = 'Allow User Modification';
        }
        field(227;"Items Out-of-Scope";Option)
        {
            Caption = 'Items Out-of-Scope';
            OptionCaption = 'Error,Ignore,Accept Count';
            OptionMembers = ERROR,IGNORE,ACCEPT_COUNT;
        }
        field(228;"Items in Scope Not Counted";Option)
        {
            Caption = 'Items in Scope Not Counted';
            OptionCaption = 'Error,Ignore,Accept Current,Adjust If Negative,Adjust Set Zero';
            OptionMembers = ERROR,IGNORE,ACCEPT_CURRENT,ADJUST_IF_NEGATIVE,ADJUST_SET_ZERO;
        }
        field(229;"Barcode Not Accepted";Option)
        {
            Caption = 'Barcode Not Accepted';
            OptionCaption = 'Error,Ignore';
            OptionMembers = ERROR,IGNORE;
        }
        field(230;"Counting Method";Option)
        {
            Caption = 'Counting Method';
            OptionCaption = 'Complete (Non-Zero),Complete,Partial';
            OptionMembers = COMPLETE_NONZERO,COMPLETE_ALL,PARTIAL;
        }
        field(231;"Suggested Unit Cost Source";Option)
        {
            Caption = 'Suggested Unit Cost Source';
            OptionCaption = 'Unit Cost,Last Direct Cost,Standard Cost';
            OptionMembers = UNIT_COST,LAST_DIRECT_COST,STANDARD_COST;
        }
        field(232;"Allow Unit Cost Change";Boolean)
        {
            Caption = 'Allow Unit Cost Change';
        }
        field(233;"Item Journal Template Name";Code[10])
        {
            Caption = 'Item Journal Template Name';
            NotBlank = true;
            TableRelation = IF ("Adjustment Method"=CONST(STOCKTAKE)) "Item Journal Template" WHERE (Type=CONST("Phys. Inventory"))
                            ELSE IF ("Adjustment Method"=CONST(ADJUSTMENT)) "Item Journal Template" WHERE (Type=CONST(Item))
                            ELSE IF ("Adjustment Method"=CONST(PURCHASE)) "Item Journal Template" WHERE (Type=CONST(Item));

            trigger OnValidate()
            begin
                if ("Item Journal Template Name" <> xRec."Item Journal Template Name") then
                  "Item Journal Batch Name" := '';
            end;
        }
        field(234;"Item Journal Batch Name";Code[20])
        {
            Caption = 'Item Journal Batch Name';
            TableRelation = "Item Journal Batch".Name WHERE ("Journal Template Name"=FIELD("Item Journal Template Name"));

            trigger OnLookup()
            begin
                TestField ("Item Journal Template Name");
                "Item Journal Batch Name" := StockTakeMgr.SelectItemJournalBatchName ("Item Journal Template Name");
            end;
        }
        field(235;"Item Journal Batch Usage";Option)
        {
            Caption = 'Item Journal Batch Usage';
            OptionCaption = 'Use Directly,As Template';
            OptionMembers = DIRECT,TEMPLATE;
        }
        field(236;"Blocked Item";Option)
        {
            Caption = 'Blocked Item';
            OptionCaption = 'Error,Ignore,Temporarily Unblock';
            OptionMembers = ERROR,IGNORE,TEMP_UNBLOCK;
        }
        field(237;"Suppress Not Counted";Boolean)
        {
            Caption = 'Suppress Not Counted';
        }
        field(238;"Stock Take Method";Option)
        {
            Caption = 'Stock Take Method';
            OptionCaption = 'By Area,By Product,By Dimension';
            OptionMembers = "AREA",PRODUCT,DIMENSION;
        }
        field(239;"Adjustment Method";Option)
        {
            Caption = 'Adjustment Method';
            OptionCaption = 'Stock-Take,Adjustment,Purchase (Adjmt.)';
            OptionMembers = STOCKTAKE,ADJUSTMENT,PURCHASE;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        StockTakeMgr: Codeunit "Stock-Take Manager";
}

