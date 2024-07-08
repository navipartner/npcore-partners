table 6060115 "NPR TM Ticket Access Stats"
{
    Caption = 'Ticket Access Statistics';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR TM Ticket Access Stats";
    LookupPageID = "NPR TM Ticket Access Stats";

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
        field(90; "Highest Access Entry No."; Integer)
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
            CalcFormula = Sum("NPR TM Ticket Access Stats"."Admission Count" WHERE("Item No." = FIELD("Item No. Filter"),
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
            CalcFormula = Sum("NPR TM Ticket Access Stats"."Admission Count (Neg)" WHERE("Item No." = FIELD("Item No. Filter"),
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
            CalcFormula = Sum("NPR TM Ticket Access Stats"."Admission Count (Re-Entry)" WHERE("Item No." = FIELD("Item No. Filter"),
                                                                                                "Ticket Type" = FIELD("Ticket Type Filter"),
                                                                                                "Admission Date" = FIELD("Admission Date Filter"),
                                                                                                "Admission Hour" = FIELD("Admission Hour Filter"),
                                                                                                "Admission Code" = FIELD("Admission Code Filter"),
                                                                                                "Variant Code" = FIELD("Variant Code Filter")));
            Caption = 'Sum Admission Count (Re-Entry)';
            Editable = false;
            FieldClass = FlowField;
        }

        field(130; "Sum Generated Count (Pos)"; Decimal)
        {
            CalcFormula = Sum("NPR TM Ticket Access Stats"."Generated Count (Pos)" WHERE("Item No." = FIELD("Item No. Filter"),
                                                                                                "Ticket Type" = FIELD("Ticket Type Filter"),
                                                                                                "Admission Date" = FIELD("Admission Date Filter"),
                                                                                                "Admission Hour" = FIELD("Admission Hour Filter"),
                                                                                                "Admission Code" = FIELD("Admission Code Filter"),
                                                                                                "Variant Code" = FIELD("Variant Code Filter")));
            Caption = 'Sum Generated Count (Pos)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(131; "Sum Generated Count (Neg)"; Decimal)
        {
            CalcFormula = Sum("NPR TM Ticket Access Stats"."Generated Count (Neg)" WHERE("Item No." = FIELD("Item No. Filter"),
                                                                                                "Ticket Type" = FIELD("Ticket Type Filter"),
                                                                                                "Admission Date" = FIELD("Admission Date Filter"),
                                                                                                "Admission Hour" = FIELD("Admission Hour Filter"),
                                                                                                "Admission Code" = FIELD("Admission Code Filter"),
                                                                                                "Variant Code" = FIELD("Variant Code Filter")));

            Caption = 'Sum Generated Count (Neg)';
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

