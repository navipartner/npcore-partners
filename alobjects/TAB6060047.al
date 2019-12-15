table 6060047 "Reg. Item Wsht Variant Line"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR5.48/BHR /20190111 CASE 341967 remove blank space from options

    Caption = 'Reg. Item Wsht Variant Line';

    fields
    {
        field(1;"Registered Worksheet No.";Integer)
        {
            Caption = 'Registered Worksheet No.';
        }
        field(3;"Registered Worksheet Line No.";Integer)
        {
            Caption = 'Registered Worksheet Line No.';
        }
        field(6;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(7;Level;Integer)
        {
            Caption = 'Level';
        }
        field(8;"Action";Option)
        {
            Caption = 'Action';
            InitValue = Undefined;
            OptionCaption = 'Skip,CreateNew,Update,Undefined';
            OptionMembers = Skip,CreateNew,Update,Undefined;
        }
        field(9;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(15;"Existing Item No.";Code[20])
        {
            Caption = 'Existing Item No.';
            TableRelation = Item."No.";
        }
        field(16;"Existing Variant Code";Code[10])
        {
            Caption = 'Existing Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Existing Item No."));
        }
        field(21;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
        }
        field(22;"Internal Bar Code";Text[30])
        {
            Caption = 'Internal Bar Code';
        }
        field(23;"Sales Price";Decimal)
        {
            Caption = 'Sales Price';
        }
        field(24;"Direct Unit Cost";Decimal)
        {
            Caption = 'Direct Unit Cost';
        }
        field(35;"Vendors Bar Code";Code[20])
        {
            Caption = 'Vendors Bar Code';
        }
        field(160;"Heading Text";Text[50])
        {
            Caption = 'Heading Text';
            Editable = false;
        }
        field(170;"Existing Variant Blocked";Boolean)
        {
            CalcFormula = Lookup("Item Variant".Blocked WHERE ("Item No."=FIELD("Existing Item No."),
                                                               Code=FIELD("Existing Variant Code")));
            Caption = 'Existing Variant Blocked';
            Editable = false;
            FieldClass = FlowField;
        }
        field(180;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(190;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
        field(6059980;"Variety 1";Code[10])
        {
            CalcFormula = Lookup("Registered Item Worksheet Line"."Variety 1" WHERE ("Registered Worksheet No."=FIELD("Registered Worksheet No."),
                                                                                     "Line No."=FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 1';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059981;"Variety 1 Table";Code[20])
        {
            CalcFormula = Lookup("Registered Item Worksheet Line"."Variety 1 Table (New)" WHERE ("Registered Worksheet No."=FIELD("Registered Worksheet No."),
                                                                                                 "Line No."=FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 1 Table';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059982;"Variety 1 Value";Code[20])
        {
            Caption = 'Variety 1 Value';
            Description = 'CASE220397';
            //This property is currently not supported
            //TestTableRelation = false;
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = false;
        }
        field(6059983;"Variety 2";Code[10])
        {
            CalcFormula = Lookup("Registered Item Worksheet Line"."Variety 2" WHERE ("Registered Worksheet No."=FIELD("Registered Worksheet No."),
                                                                                     "Line No."=FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 2';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059984;"Variety 2 Table";Code[20])
        {
            CalcFormula = Lookup("Registered Item Worksheet Line"."Variety 2 Table (New)" WHERE ("Registered Worksheet No."=FIELD("Registered Worksheet No."),
                                                                                                 "Line No."=FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 2 Table';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059985;"Variety 2 Value";Code[20])
        {
            Caption = 'Variety 2 Value';
            Description = 'CASE220397';
            //This property is currently not supported
            //TestTableRelation = false;
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = false;
        }
        field(6059986;"Variety 3";Code[10])
        {
            CalcFormula = Lookup("Registered Item Worksheet Line"."Variety 3" WHERE ("Registered Worksheet No."=FIELD("Registered Worksheet No."),
                                                                                     "Line No."=FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 3';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059987;"Variety 3 Table";Code[20])
        {
            CalcFormula = Lookup("Registered Item Worksheet Line"."Variety 3 Table (New)" WHERE ("Registered Worksheet No."=FIELD("Registered Worksheet No."),
                                                                                                 "Line No."=FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 3 Table';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059988;"Variety 3 Value";Code[20])
        {
            Caption = 'Variety 3 Value';
            Description = 'CASE220397';
            //This property is currently not supported
            //TestTableRelation = false;
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = false;

            trigger OnLookup()
            var
                VarValue: Code[20];
            begin
            end;
        }
        field(6059989;"Variety 4";Code[10])
        {
            CalcFormula = Lookup("Registered Item Worksheet Line"."Variety 4" WHERE ("Registered Worksheet No."=FIELD("Registered Worksheet No."),
                                                                                     "Line No."=FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 4';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059990;"Variety 4 Table";Code[20])
        {
            CalcFormula = Lookup("Registered Item Worksheet Line"."Variety 4 Table (New)" WHERE ("Registered Worksheet No."=FIELD("Registered Worksheet No."),
                                                                                                 "Line No."=FIELD("Registered Worksheet Line No.")));
            Caption = 'Variety 4 Table';
            Description = 'CASE220397';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059991;"Variety 4 Value";Code[20])
        {
            Caption = 'Variety 4 Value';
            Description = 'CASE220397';
            //This property is currently not supported
            //TestTableRelation = false;
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = false;

            trigger OnLookup()
            var
                VarValue: Code[20];
            begin
            end;
        }
    }

    keys
    {
        key(Key1;"Registered Worksheet No.","Registered Worksheet Line No.","Line No.")
        {
        }
        key(Key2;"Registered Worksheet No.","Registered Worksheet Line No.","Variety 1 Value","Variety 2 Value","Variety 3 Value","Variety 4 Value")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'Text001';
        Text002: Label '%1 is not part of predefined variety set %2 %3. Do you still want to add it? Adding it will make a copy of variety table %3.';
        Text003: Label 'Variety %1 Value %2 will be added to table copy.';
        Text004: Label 'Variety %1 Value %2 will be added to unlocked table.';
}

