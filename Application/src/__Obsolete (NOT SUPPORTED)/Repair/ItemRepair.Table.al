﻿table 6059982 "NPR Item Repair"
{
    Access = Internal;
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.48/JDH /20181109 CASE 334163 Added option captions
    // NPR5.49/BHR /20190218 CASE 341465 Increase size of Variety Tables from code 20 to code 40

    Caption = 'Item Repair';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Repairs are not supported in core anymore.';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Item Ledger Entry Qty."; Integer)
        {
            CalcFormula = Count("Item Ledger Entry" WHERE("Item No." = FIELD("Item No."),
                                                           "Variant Code" = FIELD("Variant Code")));
            Caption = 'Item Ledger Entry Qty.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Item Ledger Entry Exist"; Boolean)
        {
            Caption = 'Item Ledger Entry Exist';
            DataClassification = CustomerContent;
        }
        field(22; "Item Ledger Entry Open"; Boolean)
        {
            CalcFormula = Exist("Item Ledger Entry" WHERE("Item No." = FIELD("Item No."),
                                                           "Variant Code" = FIELD("Variant Code"),
                                                           Open = CONST(true)));
            Caption = 'Item Ledger Entry Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(32; "Errors Exists"; Boolean)
        {
            Caption = 'Errors Exists';
            DataClassification = CustomerContent;
        }
        field(37; "First Action"; Text[30])
        {
            Caption = 'First Action';
            DataClassification = CustomerContent;
        }
        field(40; "Variety 1 Used"; Boolean)
        {
            Caption = 'Variety 1 Used';
            DataClassification = CustomerContent;
        }
        field(41; "Variety 2 Used"; Boolean)
        {
            Caption = 'Variety 2 Used';
            DataClassification = CustomerContent;
        }
        field(42; "Variety 3 Used"; Boolean)
        {
            Caption = 'Variety 3 Used';
            DataClassification = CustomerContent;
        }
        field(43; "Variety 4 Used"; Boolean)
        {
            Caption = 'Variety 4 Used';
            DataClassification = CustomerContent;
        }
        field(6059970; "Variety 1 (Item)"; Code[10])
        {
            Caption = 'Variety 1 (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059971; "Variety 1 Table (Item)"; Code[40])
        {
            Caption = 'Variety 1 Table (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059972; "Variety 1 Value (Var) (NEW)"; Code[20])
        {
            Caption = 'Variety 1 Value (Var) (NEW)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059973; "Variety 2 (Item)"; Code[10])
        {
            Caption = 'Variety 2 (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059974; "Variety 2 Table (Item)"; Code[40])
        {
            Caption = 'Variety 2 Table (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059975; "Variety 2 Value (Var) (NEW)"; Code[20])
        {
            Caption = 'Variety 2 Value (Var) (NEW)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059976; "Variety 3 (Item)"; Code[10])
        {
            Caption = 'Variety 3 (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059977; "Variety 3 Table (Item)"; Code[40])
        {
            Caption = 'Variety 3 Table (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059978; "Variety 3 Value (Var) (NEW)"; Code[20])
        {
            Caption = 'Variety 3 Value (Var) (NEW)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059979; "Variety 4 (Item)"; Code[10])
        {
            Caption = 'Variety 4 (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059980; "Variety 4 Table (Item)"; Code[40])
        {
            Caption = 'Variety 4 Table (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059981; "Cross Variety No."; Option)
        {
            Caption = 'Cross Variety No.';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            OptionCaption = 'Variety 1,Variety 2,Variety 3,Variety 4';
            OptionMembers = Variety1,Variety2,Variety3,Variety4;
        }
        field(6059982; "Variety Group"; Code[20])
        {
            Caption = 'Variety Group';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059983; "Variety 4 Value (Var) (NEW)"; Code[20])
        {
            Caption = 'Variety 4 Value (Var) (NEW)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059990; "Variety 1 (Var)"; Code[10])
        {
            Caption = 'Variety 1 (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059991; "Variety 1 Table (Var)"; Code[40])
        {
            Caption = 'Variety 1 Table (Var)';
            DataClassification = CustomerContent;
        }
        field(6059992; "Variety 1 Value (Var)"; Code[20])
        {
            Caption = 'Variety 1 Value (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059993; "Variety 2 (Var)"; Code[10])
        {
            Caption = 'Variety 2 (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059994; "Variety 2 Table (Var)"; Code[40])
        {
            Caption = 'Variety 2 Table (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059995; "Variety 2 Value (Var)"; Code[20])
        {
            Caption = 'Variety 2 Value (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059996; "Variety 3 (Var)"; Code[10])
        {
            Caption = 'Variety 3 (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059997; "Variety 3 Table (Var)"; Code[40])
        {
            Caption = 'Variety 3 Table (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059998; "Variety 3 Value (Var)"; Code[20])
        {
            Caption = 'Variety 3 Value (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059999; "Variety 4 (Var)"; Code[10])
        {
            Caption = 'Variety 4 (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6060000; "Variety 4 Table (Var)"; Code[40])
        {
            Caption = 'Variety 4 Table (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6060001; "Variety 4 Value (Var)"; Code[20])
        {
            Caption = 'Variety 4 Value (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6060002; "Blocked (Var)"; Boolean)
        {
            Caption = 'Blocked (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code")
        {
        }
    }

    fieldgroups
    {
    }
}

