﻿table 6150671 "NPR NPRE W.Pad Prnt LogEntry"
{
    Access = Internal;
    Caption = 'W. Pad Line Send Log Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE W.Pad Pr.Log Entries";
    LookupPageID = "NPR NPRE W.Pad Pr.Log Entries";

    fields
    {
        field(1; "Waiter Pad No."; Code[20])
        {
            Caption = 'Waiter Pad No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Waiter Pad";
        }
        field(2; "Waiter Pad Line No."; Integer)
        {
            Caption = 'Waiter Pad Line No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Waiter Pad Line"."Line No." WHERE("Waiter Pad No." = FIELD("Waiter Pad No."));
        }
        field(4; "Print Category Code"; Code[20])
        {
            Caption = 'Print Category Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Print/Prod. Cat.";
        }
        field(5; "Flow Status Object"; Enum "NPR NPRE Status Object")
        {
            Caption = 'Flow Status Object';
            DataClassification = CustomerContent;
        }
        field(6; "Flow Status Code"; Code[10])
        {
            Caption = 'Serving Step Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = FIELD("Flow Status Object"));
        }
        field(7; "Print Type"; Option)
        {
            Caption = 'Request Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Kitchen Order,Serving Request';
            OptionMembers = "Kitchen Order","Serving Request";
        }
        field(10; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(20; "Output Type"; Option)
        {
            Caption = 'Output Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            OptionCaption = 'Print,KDS';
            OptionMembers = Print,KDS;
        }
        field(30; "Sent Date-Time"; DateTime)
        {
            Caption = 'Sent Date-Time';
            DataClassification = CustomerContent;
        }
        field(40; "Sent Quanity (Base)"; Decimal)
        {
            Caption = 'Sent Quanity (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.55';
        }
        field(50; Context; Option)
        {
            Caption = 'Context';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            OptionCaption = 'Ordering,Line Splitting';
            OptionMembers = Ordering,"Line Splitting";
        }
        field(60; "Waiter Pad Line Exists"; Boolean)
        {
            Caption = 'Waiter Pad Line Exists';
            FieldClass = FlowField;
            CalcFormula = Exist("NPR NPRE Waiter Pad Line" where("Waiter Pad No." = field("Waiter Pad No."), "Line No." = field("Waiter Pad Line No.")));
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Waiter Pad No.", "Waiter Pad Line No.", "Print Type", "Print Category Code", "Flow Status Object", "Flow Status Code", "Output Type")
        {
            SumIndexFields = "Sent Quanity (Base)";
        }
    }
}
