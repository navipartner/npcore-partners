table 6060115 "TM Ticket Access Statistics"
{
    // NPR4.14/TSA/20150803/CASE214262 - Initial Version
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.17/TSA/20161025  CASE 256152 Conform to OMA Guidelines
    // TM1.22/TSA/20170530  CASE 274464 Adjusted stat engine to handle non-linear time when aggregating, new field Highest Access Entry No. and key
    // TM1.36/TSA /20180727 CASE 323024 Added Variant Code field
    // TM1.36/TSA /20180727 CASE 323400 Added flowfield on "Sum Admission Count (Re-Entry)"
    // #334163/JDH /20181109 CASE 334163 Added Caption to field Highest Access Entry No.
    // TM1.39/NPKNAV/20190125  CASE 343941 Transport TM1.39 - 25 January 2019

    Caption = 'Ticket Access Statistics';
    DataClassification = CustomerContent;
    DrillDownPageID = "TM Ticket Access Statistics";
    LookupPageID = "TM Ticket Access Statistics";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(11; "Ticket Type"; Code[20])
        {
            Caption = 'Ticket Type';
            DataClassification = CustomerContent;
        }
        field(12; "Admission Date"; Date)
        {
            Caption = 'Admission Date';
            DataClassification = CustomerContent;
        }
        field(13; "Admission Hour"; Integer)
        {
            Caption = 'Admission Hour';
            DataClassification = CustomerContent;
        }
        field(14; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(15; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(20; "Admission Count"; Decimal)
        {
            Caption = 'Admission Count';
            DataClassification = CustomerContent;
        }
        field(22; "Admission Count (Neg)"; Decimal)
        {
            Caption = 'Admission Count (Neg)';
            DataClassification = CustomerContent;
        }
        field(23; "Admission Count (Re-Entry)"; Decimal)
        {
            Caption = 'Admission Count (Re-Entry)';
            DataClassification = CustomerContent;
        }
        field(30; "Generated Count (Pos)"; Decimal)
        {
            Caption = 'Generated Count (Pos)';
            DataClassification = CustomerContent;
        }
        field(31; "Generated Count (Neg)"; Decimal)
        {
            Caption = 'Generated Count (Neg)';
            DataClassification = CustomerContent;
        }
        field(90; "Highest Access Entry No."; BigInteger)
        {
            Caption = 'Highest Access Entry No.';
            DataClassification = CustomerContent;
        }
        field(110; "Item No. Filter"; Code[20])
        {
            Caption = 'Item No. Filter';
            FieldClass = FlowFilter;
        }
        field(111; "Ticket Type Filter"; Code[20])
        {
            Caption = 'Ticket Type Filter';
            FieldClass = FlowFilter;
        }
        field(112; "Admission Date Filter"; Date)
        {
            Caption = 'Admission Date Filter';
            FieldClass = FlowFilter;
        }
        field(113; "Admission Hour Filter"; Integer)
        {
            Caption = 'Admission Hour Filter';
            FieldClass = FlowFilter;
        }
        field(114; "Admission Code Filter"; Code[20])
        {
            Caption = 'Admission Code Filter';
            FieldClass = FlowFilter;
        }
        field(115; "Variant Code Filter"; Code[10])
        {
            Caption = 'Variant Code Filter';
            FieldClass = FlowFilter;
        }
        field(120; "Sum Admission Count"; Decimal)
        {
            CalcFormula = Sum ("TM Ticket Access Statistics"."Admission Count" WHERE("Item No." = FIELD("Item No. Filter"),
                                                                                     "Ticket Type" = FIELD("Ticket Type Filter"),
                                                                                     "Admission Date" = FIELD("Admission Date Filter"),
                                                                                     "Admission Hour" = FIELD("Admission Hour Filter"),
                                                                                     "Admission Code" = FIELD("Admission Code Filter"),
                                                                                     "Variant Code" = FIELD("Variant Code Filter")));
            Caption = 'Sum Admission Count';
            Editable = false;
            FieldClass = FlowField;
        }
        field(122; "Sum Admission Count (Neg)"; Decimal)
        {
            CalcFormula = Sum ("TM Ticket Access Statistics"."Admission Count (Neg)" WHERE("Item No." = FIELD("Item No. Filter"),
                                                                                           "Ticket Type" = FIELD("Ticket Type Filter"),
                                                                                           "Admission Date" = FIELD("Admission Date Filter"),
                                                                                           "Admission Hour" = FIELD("Admission Hour Filter"),
                                                                                           "Admission Code" = FIELD("Admission Code Filter"),
                                                                                           "Variant Code" = FIELD("Variant Code Filter")));
            Caption = 'Sum Admission Count (Neg)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(123; "Sum Admission Count (Re-Entry)"; Decimal)
        {
            CalcFormula = Sum ("TM Ticket Access Statistics"."Admission Count (Re-Entry)" WHERE("Item No." = FIELD("Item No. Filter"),
                                                                                                "Ticket Type" = FIELD("Ticket Type Filter"),
                                                                                                "Admission Date" = FIELD("Admission Date Filter"),
                                                                                                "Admission Hour" = FIELD("Admission Hour Filter"),
                                                                                                "Admission Code" = FIELD("Admission Code Filter"),
                                                                                                "Variant Code" = FIELD("Variant Code Filter")));
            Caption = 'Sum Admission Count (Re-Entry)';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Item No.", "Ticket Type", "Admission Code", "Admission Date", "Admission Hour")
        {
            SumIndexFields = "Admission Count", "Admission Count (Neg)";
        }
        key(Key3; "Highest Access Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

