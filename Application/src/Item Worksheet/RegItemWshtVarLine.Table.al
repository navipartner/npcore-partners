table 6060047 "NPR Reg. Item Wsht Var. Line"
{
    Access = Internal;
    Caption = 'Reg. Item Wsht Variant Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Registered Worksheet No."; Integer)
        {
            Caption = 'Registered Worksheet No.';
            DataClassification = CustomerContent;
        }
        field(3; "Registered Worksheet Line No."; Integer)
        {
            Caption = 'Registered Worksheet Line No.';
            DataClassification = CustomerContent;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(7; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;
        }
        field(8; "Action"; Option)
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
            InitValue = Undefined;
            OptionCaption = 'Skip,CreateNew,Update,Undefined';
            OptionMembers = Skip,CreateNew,Update,Undefined;
        }
        field(9; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(15; "Existing Item No."; Code[20])
        {
            Caption = 'Existing Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(16; "Existing Variant Code"; Code[10])
        {
            Caption = 'Existing Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Existing Item No."));
        }
        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(22; "Internal Bar Code"; Text[30])
        {
            Caption = 'Internal Bar Code';
            DataClassification = CustomerContent;
        }
        field(23; "Sales Price"; Decimal)
        {
            Caption = 'Sales Price';
            DataClassification = CustomerContent;
        }
        field(24; "Direct Unit Cost"; Decimal)
        {
            Caption = 'Direct Unit Cost';
            DataClassification = CustomerContent;
        }
        field(35; "Vendors Bar Code"; Code[20])
        {
            Caption = 'Vendors Bar Code';
            DataClassification = CustomerContent;
        }
        field(160; "Heading Text"; Text[50])
        {
            Caption = 'Heading Text';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(170; "Existing Variant Blocked"; Boolean)
        {
            CalcFormula = Lookup("Item Variant"."NPR Blocked" WHERE("Item No." = FIELD("Existing Item No."),
                                                               Code = FIELD("Existing Variant Code")));
            Caption = 'Existing Variant Blocked';
            Editable = false;
            FieldClass = FlowField;
        }
        field(180; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(190; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(6059980; "Variety 1"; Code[10])
        {
            CalcFormula = Lookup("NPR Regist. Item Worksh Line"."Variety 1" WHERE("Registered Worksheet No." = FIELD("Registered Worksheet No."),
                                                                                     "Line No." = FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 1';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059981; "Variety 1 Table"; Code[20])
        {
            CalcFormula = Lookup("NPR Regist. Item Worksh Line"."Variety 1 Table (New)" WHERE("Registered Worksheet No." = FIELD("Registered Worksheet No."),
                                                                                                 "Line No." = FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 1 Table';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059982; "Variety 1 Value"; Code[50])
        {
            Caption = 'Variety 1 Value';
            DataClassification = CustomerContent;
            Description = 'CASE220397';
        }
        field(6059983; "Variety 2"; Code[10])
        {
            CalcFormula = Lookup("NPR Regist. Item Worksh Line"."Variety 2" WHERE("Registered Worksheet No." = FIELD("Registered Worksheet No."),
                                                                                     "Line No." = FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 2';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059984; "Variety 2 Table"; Code[20])
        {
            CalcFormula = Lookup("NPR Regist. Item Worksh Line"."Variety 2 Table (New)" WHERE("Registered Worksheet No." = FIELD("Registered Worksheet No."),
                                                                                                 "Line No." = FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 2 Table';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059985; "Variety 2 Value"; Code[50])
        {
            Caption = 'Variety 2 Value';
            DataClassification = CustomerContent;
            Description = 'CASE220397';
        }
        field(6059986; "Variety 3"; Code[10])
        {
            CalcFormula = Lookup("NPR Regist. Item Worksh Line"."Variety 3" WHERE("Registered Worksheet No." = FIELD("Registered Worksheet No."),
                                                                                     "Line No." = FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 3';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059987; "Variety 3 Table"; Code[20])
        {
            CalcFormula = Lookup("NPR Regist. Item Worksh Line"."Variety 3 Table (New)" WHERE("Registered Worksheet No." = FIELD("Registered Worksheet No."),
                                                                                                 "Line No." = FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 3 Table';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059988; "Variety 3 Value"; Code[50])
        {
            Caption = 'Variety 3 Value';
            DataClassification = CustomerContent;
            Description = 'CASE220397';

            trigger OnLookup()
            begin
            end;
        }
        field(6059989; "Variety 4"; Code[10])
        {
            CalcFormula = Lookup("NPR Regist. Item Worksh Line"."Variety 4" WHERE("Registered Worksheet No." = FIELD("Registered Worksheet No."),
                                                                                     "Line No." = FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 4';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059990; "Variety 4 Table"; Code[20])
        {
            CalcFormula = Lookup("NPR Regist. Item Worksh Line"."Variety 4 Table (New)" WHERE("Registered Worksheet No." = FIELD("Registered Worksheet No."),
                                                                                                 "Line No." = FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 4 Table';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059991; "Variety 4 Value"; Code[50])
        {
            Caption = 'Variety 4 Value';
            DataClassification = CustomerContent;
            Description = 'CASE220397';

            trigger OnLookup()
            begin
            end;
        }
    }

    keys
    {
        key(Key1; "Registered Worksheet No.", "Registered Worksheet Line No.", "Line No.")
        {
        }
        key(Key2; "Registered Worksheet No.", "Registered Worksheet Line No.", "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value")
        {
        }
    }
}

