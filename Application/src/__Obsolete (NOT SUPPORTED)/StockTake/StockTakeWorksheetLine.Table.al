table 6014664 "NPR Stock-Take Worksheet Line"
{
    Caption = 'Statement Line';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';

    fields
    {
        field(1; "Stock-Take Config Code"; Code[10])
        {
            Caption = 'Stock-Take Conf. Code';
            DataClassification = CustomerContent;
        }
        field(2; "Worksheet Name"; Code[10])
        {
            Caption = 'Worksheet Name';
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
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(12; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
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
        }
        field(15; "Date of Inventory"; Date)
        {
            Caption = 'Date of Inventory';
            DataClassification = CustomerContent;
        }
        field(20; "Shelf  No."; Code[10])
        {
            Caption = 'Shelf  No.';
            DataClassification = CustomerContent;
        }
        field(34; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(35; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
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
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(500; "Item Tracking Code"; Code[10])
        {
            Caption = 'Item Tracking Code';
            Editable = false;
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
}