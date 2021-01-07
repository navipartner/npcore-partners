table 6014666 "NPR Stock-Take Template"
{
    Caption = 'Stock-Take Template';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';
    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(210; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(211; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(212; "Item Group Filter"; Text[200])
        {
            Caption = 'Item Group Filter';
            DataClassification = CustomerContent;
        }
        field(213; "Vendor Code Filter"; Text[200])
        {
            Caption = 'Vendor Code Filter';
            DataClassification = CustomerContent;
        }
        field(214; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(215; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
        }
        field(220; "Session Based Loading"; Option)
        {
            Caption = 'Session Based Loading';
            OptionCaption = 'Append,Append Until Transferred,Append Is Not Allowed';
            OptionMembers = APPEND,APPEND_UNTIL_TRANSFERRED,APPEND_NOT_ALLOWED;
            DataClassification = CustomerContent;
        }
        field(221; "Session Based Transfer"; Option)
        {
            Caption = 'Session Based Transfer';
            OptionCaption = 'All Worksheets,Single Worksheet,Selected Lines';
            OptionMembers = ALL_WORKSHEETS,WORKSHEET,SELECTED_LINES;
            DataClassification = CustomerContent;
        }
        field(222; "Aggregation Level"; Option)
        {
            Caption = 'Aggregation Level';
            OptionCaption = 'Scanned Number,Session Name,Native,Consecutive';
            OptionMembers = SCANNED_NUMBER,SESSION,NATIVE,CONSECUTIVE;
            DataClassification = CustomerContent;
        }
        field(223; "Data Release"; Option)
        {
            Caption = 'Data Release';
            OptionCaption = 'Manual,Per Transfer,Final Transfer';
            OptionMembers = MANUAL,ON_TRANSFER,ON_FINAL_TRANSFER;
            DataClassification = CustomerContent;
        }
        field(224; "Transfer Action"; Option)
        {
            Caption = 'Transfer Action';
            OptionCaption = 'Transfer,Transfer and Post,Transfer Post and Print';
            OptionMembers = TRANSFER,TRANSFER_POST,TRANSFER_POST_PRINT;
            DataClassification = CustomerContent;
        }
        field(225; "Defaul Profile"; Boolean)
        {
            Caption = 'Default Profile';
            DataClassification = CustomerContent;
        }
        field(226; "Allow User Modification"; Boolean)
        {
            Caption = 'Allow User Modification';
            DataClassification = CustomerContent;
        }
        field(227; "Items Out-of-Scope"; Option)
        {
            Caption = 'Items Out-of-Scope';
            OptionCaption = 'Error,Ignore,Accept Count';
            OptionMembers = ERROR,IGNORE,ACCEPT_COUNT;
            DataClassification = CustomerContent;
        }
        field(228; "Items in Scope Not Counted"; Option)
        {
            Caption = 'Items in Scope Not Counted';
            OptionCaption = 'Error,Ignore,Accept Current,Adjust If Negative,Adjust Set Zero';
            OptionMembers = ERROR,IGNORE,ACCEPT_CURRENT,ADJUST_IF_NEGATIVE,ADJUST_SET_ZERO;
            DataClassification = CustomerContent;
        }
        field(229; "Barcode Not Accepted"; Option)
        {
            Caption = 'Barcode Not Accepted';
            OptionCaption = 'Error,Ignore';
            OptionMembers = ERROR,IGNORE;
            DataClassification = CustomerContent;
        }
        field(230; "Counting Method"; Option)
        {
            Caption = 'Counting Method';
            OptionCaption = 'Complete (Non-Zero),Complete,Partial';
            OptionMembers = COMPLETE_NONZERO,COMPLETE_ALL,PARTIAL;
            DataClassification = CustomerContent;
        }
        field(231; "Suggested Unit Cost Source"; Option)
        {
            Caption = 'Suggested Unit Cost Source';
            OptionCaption = 'Unit Cost,Last Direct Cost,Standard Cost';
            OptionMembers = UNIT_COST,LAST_DIRECT_COST,STANDARD_COST;
            DataClassification = CustomerContent;
        }
        field(232; "Allow Unit Cost Change"; Boolean)
        {
            Caption = 'Allow Unit Cost Change';
            DataClassification = CustomerContent;
        }
        field(233; "Item Journal Template Name"; Code[10])
        {
            Caption = 'Item Journal Template Name';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(234; "Item Journal Batch Name"; Code[20])
        {
            Caption = 'Item Journal Batch Name';
            DataClassification = CustomerContent;
        }
        field(235; "Item Journal Batch Usage"; Option)
        {
            Caption = 'Item Journal Batch Usage';
            OptionCaption = 'Use Directly,As Template';
            OptionMembers = DIRECT,TEMPLATE;
            DataClassification = CustomerContent;
        }
        field(236; "Blocked Item"; Option)
        {
            Caption = 'Blocked Item';
            OptionCaption = 'Error,Ignore,Temporarily Unblock';
            OptionMembers = ERROR,IGNORE,TEMP_UNBLOCK;
            DataClassification = CustomerContent;
        }
        field(237; "Suppress Not Counted"; Boolean)
        {
            Caption = 'Suppress Not Counted';
            DataClassification = CustomerContent;
        }
        field(238; "Stock Take Method"; Option)
        {
            Caption = 'Stock Take Method';
            OptionCaption = 'By Area,By Product,By Dimension';
            OptionMembers = "AREA",PRODUCT,DIMENSION;
            DataClassification = CustomerContent;
        }
        field(239; "Adjustment Method"; Option)
        {
            Caption = 'Adjustment Method';
            OptionCaption = 'Stock-Take,Adjustment,Purchase (Adjmt.)';
            OptionMembers = STOCKTAKE,ADJUSTMENT,PURCHASE;
            DataClassification = CustomerContent;
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

}