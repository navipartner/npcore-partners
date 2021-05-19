table 6150624 "NPR POS Balancing Line"
{
    Caption = 'POS Balancing Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(3; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(4; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(7; "POS Period Register No."; Integer)
        {
            Caption = 'POS Period Register No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = "NPR POS Period Register";
        }
        field(10; "POS Payment Bin Code"; Code[10])
        {
            Caption = 'POS Payment Bin Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin";
        }
        field(11; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(30; "Calculated Amount"; Decimal)
        {
            Caption = 'Calculated Amount';
            DataClassification = CustomerContent;
        }
        field(31; "Balanced Amount"; Decimal)
        {
            Caption = 'Balanced Amount';
            DataClassification = CustomerContent;
        }
        field(32; "Balanced Diff. Amount"; Decimal)
        {
            Caption = 'Balanced Diff. Amount';
            DataClassification = CustomerContent;
        }
        field(34; "New Float Amount"; Decimal)
        {
            Caption = 'Closing Amount';
            DataClassification = CustomerContent;
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(50; "Calculated Quantity"; Decimal)
        {
            Caption = 'Calculated Quantity';
            DataClassification = CustomerContent;
        }
        field(51; "Balanced Quantity"; Decimal)
        {
            Caption = 'Balanced Quantity';
            DataClassification = CustomerContent;
        }
        field(52; "Balanced Diff. Quantity"; Decimal)
        {
            Caption = 'Balanced Diff. Quantity';
            DataClassification = CustomerContent;
        }
        field(53; "Deposited Quantity"; Decimal)
        {
            Caption = 'Deposited Quantity';
            DataClassification = CustomerContent;
        }
        field(54; "Closing Quantity"; Decimal)
        {
            Caption = 'Closing Quantity';
            DataClassification = CustomerContent;
        }
        field(60; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(70; "Deposit-To Bin Amount"; Decimal)
        {
            Caption = 'Deposited Amount';
            DataClassification = CustomerContent;
        }
        field(71; "Deposit-To Bin Code"; Code[10])
        {
            Caption = 'Deposit-To Bin Code';
            DataClassification = CustomerContent;
        }
        field(72; "Deposit-To Reference"; Text[50])
        {
            Caption = 'Deposit-To Reference';
            DataClassification = CustomerContent;
        }
        field(80; "Move-To Bin Amount"; Decimal)
        {
            Caption = 'Move-To Bin Amount';
            DataClassification = CustomerContent;
        }
        field(81; "Move-To Bin Code"; Code[10])
        {
            Caption = 'Transfer-To POS Bin Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin";
        }
        field(82; "Move-To Reference"; Text[50])
        {
            Caption = 'Move-To Reference';
            DataClassification = CustomerContent;
        }
        field(100; "Balancing Details"; Text[250])
        {
            Caption = 'Balancing Details';
            DataClassification = CustomerContent;
        }
        field(160; "Orig. POS Sale ID"; Integer)
        {
            Caption = 'Orig. POS Sale ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
            ObsoleteState = Removed;
            ObsoleteReason = 'Use systemID instead';
        }
        field(161; "Orig. POS Line No."; Integer)
        {
            Caption = 'Orig. POS Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
            ObsoleteState = Removed;
            ObsoleteReason = 'Use systemID instead';
        }
        field(200; "POS Bin Checkpoint Entry No."; Integer)
        {
            Caption = 'POS Bin Checkpoint Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin Checkp.";
        }
        field(210; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(600; "Entry Date"; Date)
        {
            CalcFormula = Lookup("NPR POS Entry"."Entry Date" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Entry Date';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(610; "Starting Time"; Time)
        {
            CalcFormula = Lookup("NPR POS Entry"."Starting Time" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Starting Time';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(620; "Ending Time"; Time)
        {
            CalcFormula = Lookup("NPR POS Entry"."Ending Time" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Ending Time';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "POS Entry No.", "Line No.")
        {
        }
        key(Key2; "Document No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

