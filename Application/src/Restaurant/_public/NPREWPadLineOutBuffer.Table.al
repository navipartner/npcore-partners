table 6151292 "NPR NPRE W.Pad.Line Out.Buffer"
{
    Caption = 'Waiter Pad Line Output Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Waiter Pad No."; Code[20])
        {
            Caption = 'Waiter Pad No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Waiter Pad";
        }
        field(20; "Codeunit ID"; Integer)
        {
            Caption = 'Codeunit ID';
            DataClassification = CustomerContent;
        }
        field(30; "Print Category Code"; Code[20])
        {
            Caption = 'Print Category Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Print/Prod. Cat.";
        }
        field(40; "Serving Step"; Code[10])
        {
            Caption = 'Serving Step';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow));
        }
        field(50; "Output Type"; Option)
        {
            Caption = 'Output Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Print,KDS';
            OptionMembers = Print,KDS;
        }
        field(60; "Waiter Pad Line No."; Integer)
        {
            Caption = 'Waiter Pad Line No.';
            DataClassification = CustomerContent;
        }
        field(70; "Line Type"; Enum "NPR NPRE Kitchen PrintLineType")
        {
            Caption = 'Line Type';
            DataClassification = CustomerContent;
        }
        field(80; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(90; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(100; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(110; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(120; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
        }
        field(130; "Attached to Line No."; Integer)
        {
            Caption = 'Attached to Line No.';
            DataClassification = CustomerContent;
        }
        field(140; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
        }
        field(150; "Amount Excl. VAT"; Decimal)
        {
            Caption = 'Amount Excl. VAT';
            DataClassification = CustomerContent;
        }
        field(160; "Amount Incl. VAT"; Decimal)
        {
            Caption = 'Amount Incl. VAT';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Output Type", "Waiter Pad No.", "Codeunit ID", "Serving Step", "Print Category Code", "Waiter Pad Line No.")
        {
        }
    }
}
