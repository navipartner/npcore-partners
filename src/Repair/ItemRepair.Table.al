table 6059982 "NPR Item Repair"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.48/JDH /20181109 CASE 334163 Added option captions
    // NPR5.49/BHR /20190218 CASE 341465 Increase size of Variety Tables from code 20 to code 40

    Caption = 'Item Repair';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Item Repair";
    LookupPageID = "NPR Item Repair";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Item Ledger Entry Qty."; Integer)
        {
            CalcFormula = Count ("Item Ledger Entry" WHERE("Item No." = FIELD("Item No."),
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
            CalcFormula = Exist ("Item Ledger Entry" WHERE("Item No." = FIELD("Item No."),
                                                           "Variant Code" = FIELD("Variant Code"),
                                                           Open = CONST(true)));
            Caption = 'Item Ledger Entry Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "No. Of tests"; Integer)
        {
            CalcFormula = Count ("NPR Item Repair Tests" WHERE("Item No." = FIELD("Item No."),
                                                           "Variant Code" = FIELD("Variant Code")));
            Caption = 'No. Of tests';
            Editable = false;
            FieldClass = FlowField;
        }
        field(31; "No.Of Errors"; Integer)
        {
            CalcFormula = Count ("NPR Item Repair Tests" WHERE("Item No." = FIELD("Item No."),
                                                           "Variant Code" = FIELD("Variant Code"),
                                                           Success = CONST(false)));
            Caption = 'No.Of Errors';
            Editable = false;
            FieldClass = FlowField;
        }
        field(32; "Errors Exists"; Boolean)
        {
            Caption = 'Errors Exists';
            DataClassification = CustomerContent;
        }
        field(35; "No. Of Variant Actions"; Integer)
        {
            CalcFormula = Count ("NPR Item Repair Action" WHERE("Item No." = FIELD("Item No."),
                                                            "Variant Code" = FIELD("Variant Code")));
            Caption = 'No. Of Variant Actions';
            Editable = false;
            FieldClass = FlowField;
        }
        field(36; "No. Of Item Actions"; Integer)
        {
            CalcFormula = Count ("NPR Item Repair Action" WHERE("Item No." = FIELD("Item No."),
                                                            "Variant Code" = CONST('')));
            Caption = 'No. Of Item Actions';
            Editable = false;
            FieldClass = FlowField;
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
        field(50; "Variant Action"; Option)
        {
            CalcFormula = Lookup ("NPR Item Repair Action"."Variant Action" WHERE("Item No." = FIELD("Item No."),
                                                                              "Variant Code" = FIELD("Variant Code")));
            Caption = 'Variant Action';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'None,Block Variant,Delete Variant,Update From Item';
            OptionMembers = "None",BlockVariant,DeleteVariant,UpdateFromItem;
        }
        field(51; "Variety 1 Action"; Option)
        {
            CalcFormula = Lookup ("NPR Item Repair Action"."Variety 1 Action" WHERE("Item No." = FIELD("Item No.")));
            Caption = 'Variety 1 Action';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'None,Use Variant Setup,Use Item Setup,Select Manual';
            OptionMembers = "None",UseVariantSetup,UseItemSetup,SelectManual;
        }
        field(52; "Variety 2 Action"; Option)
        {
            CalcFormula = Lookup ("NPR Item Repair Action"."Variety 2 Action" WHERE("Item No." = FIELD("Item No.")));
            Caption = 'Variety 2 Action';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'None,Use Variant Setup,Use Item Setup,Select Manual';
            OptionMembers = "None",UseVariantSetup,UseItemSetup,SelectManual;
        }
        field(53; "Variety 3 Action"; Option)
        {
            CalcFormula = Lookup ("NPR Item Repair Action"."Variety 3 Action" WHERE("Item No." = FIELD("Item No.")));
            Caption = 'Variety 3 Action';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'None,Use Variant Setup,Use Item Setup,Select Manual';
            OptionMembers = "None",UseVariantSetup,UseItemSetup,SelectManual;
        }
        field(54; "Variety 4 Action"; Option)
        {
            CalcFormula = Lookup ("NPR Item Repair Action"."Variety 4 Action" WHERE("Item No." = FIELD("Item No.")));
            Caption = 'Variety 4 Action';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'None,Use Variant Setup,Use Item Setup,Select Manual';
            OptionMembers = "None",UseVariantSetup,UseItemSetup,SelectManual;
        }
        field(6059970; "Variety 1 (Item)"; Code[10])
        {
            Caption = 'Variety 1 (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety";
        }
        field(6059971; "Variety 1 Table (Item)"; Code[40])
        {
            Caption = 'Variety 1 Table (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 1 (Item)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059972; "Variety 1 Value (Var) (NEW)"; Code[20])
        {
            Caption = 'Variety 1 Value (Var) (NEW)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = IF ("Variety 1 (Var)" = FILTER(<> '')) "NPR Variety Value".Value WHERE(Type = FIELD("Variety 1 (Var)"),
                                                                                             Table = FIELD("Variety 1 Table (Var)"))
            ELSE
            IF ("Variety 1 (Item)" = FILTER(<> '')) "NPR Variety Value".Value WHERE(Type = FIELD("Variety 1 (Item)"),
                                                                                                                                                                    Table = FIELD("Variety 1 Table (Item)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059973; "Variety 2 (Item)"; Code[10])
        {
            Caption = 'Variety 2 (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety";
        }
        field(6059974; "Variety 2 Table (Item)"; Code[40])
        {
            Caption = 'Variety 2 Table (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 2 (Item)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059975; "Variety 2 Value (Var) (NEW)"; Code[20])
        {
            Caption = 'Variety 2 Value (Var) (NEW)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = IF ("Variety 2 (Var)" = FILTER(<> '')) "NPR Variety Value".Value WHERE(Type = FIELD("Variety 2 (Var)"),
                                                                                             Table = FIELD("Variety 2 Table (Var)"))
            ELSE
            IF ("Variety 2 (Item)" = FILTER(<> '')) "NPR Variety Value".Value WHERE(Type = FIELD("Variety 2 (Item)"),
                                                                                                                                                                    Table = FIELD("Variety 2 Table (Item)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059976; "Variety 3 (Item)"; Code[10])
        {
            Caption = 'Variety 3 (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety";
        }
        field(6059977; "Variety 3 Table (Item)"; Code[40])
        {
            Caption = 'Variety 3 Table (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 3 (Item)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059978; "Variety 3 Value (Var) (NEW)"; Code[20])
        {
            Caption = 'Variety 3 Value (Var) (NEW)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = IF ("Variety 3 (Var)" = FILTER(<> '')) "NPR Variety Value".Value WHERE(Type = FIELD("Variety 3 (Var)"),
                                                                                             Table = FIELD("Variety 3 Table (Var)"))
            ELSE
            IF ("Variety 3 (Item)" = FILTER(<> '')) "NPR Variety Value".Value WHERE(Type = FIELD("Variety 3 (Item)"),
                                                                                                                                                                    Table = FIELD("Variety 3 Table (Item)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059979; "Variety 4 (Item)"; Code[10])
        {
            Caption = 'Variety 4 (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety";
        }
        field(6059980; "Variety 4 Table (Item)"; Code[40])
        {
            Caption = 'Variety 4 Table (Item)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 4 (Item)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
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
            TableRelation = "NPR Variety Group";
        }
        field(6059983; "Variety 4 Value (Var) (NEW)"; Code[20])
        {
            Caption = 'Variety 4 Value (Var) (NEW)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = IF ("Variety 4 (Var)" = FILTER(<> '')) "NPR Variety Value".Value WHERE(Type = FIELD("Variety 4 (Var)"),
                                                                                             Table = FIELD("Variety 4 Table (Var)"))
            ELSE
            IF ("Variety 4 (Item)" = FILTER(<> '')) "NPR Variety Value".Value WHERE(Type = FIELD("Variety 4 (Item)"),
                                                                                                                                                                    Table = FIELD("Variety 4 Table (Item)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059990; "Variety 1 (Var)"; Code[10])
        {
            Caption = 'Variety 1 (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety";
        }
        field(6059991; "Variety 1 Table (Var)"; Code[40])
        {
            Caption = 'Variety 1 Table (Var)';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 1 (Var)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059992; "Variety 1 Value (Var)"; Code[20])
        {
            Caption = 'Variety 1 Value (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Value".Value WHERE(Type = FIELD("Variety 1 (Var)"),
                                                         Table = FIELD("Variety 1 Table (Var)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059993; "Variety 2 (Var)"; Code[10])
        {
            Caption = 'Variety 2 (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety";
        }
        field(6059994; "Variety 2 Table (Var)"; Code[40])
        {
            Caption = 'Variety 2 Table (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 2 (Var)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059995; "Variety 2 Value (Var)"; Code[20])
        {
            Caption = 'Variety 2 Value (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Value".Value WHERE(Type = FIELD("Variety 2 (Var)"),
                                                         Table = FIELD("Variety 2 Table (Var)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059996; "Variety 3 (Var)"; Code[10])
        {
            Caption = 'Variety 3 (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety";
        }
        field(6059997; "Variety 3 Table (Var)"; Code[40])
        {
            Caption = 'Variety 3 Table (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 3 (Var)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059998; "Variety 3 Value (Var)"; Code[20])
        {
            Caption = 'Variety 3 Value (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Value".Value WHERE(Type = FIELD("Variety 3 (Var)"),
                                                         Table = FIELD("Variety 3 Table (Var)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6059999; "Variety 4 (Var)"; Code[10])
        {
            Caption = 'Variety 4 (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety";
        }
        field(6060000; "Variety 4 Table (Var)"; Code[40])
        {
            Caption = 'Variety 4 Table (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 4 (Var)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6060001; "Variety 4 Value (Var)"; Code[20])
        {
            Caption = 'Variety 4 Value (Var)';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Value".Value WHERE(Type = FIELD("Variety 4 (Var)"),
                                                         Table = FIELD("Variety 4 Table (Var)"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
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

