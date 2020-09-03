table 6150629 "NPR POS Tax Amount Line"
{
    // NPR5.36/NPKNAV/20171003  CASE 279552 Transport NPR5.36 - 3 October 2017
    // NPR5.48/BHR /20190122 CASE 341968 Increase length of field 10030 from text30 to text 50
    // NPR5.53/SARA/20191024 CASE 373672 Added Page 'POS Tax Line List' as LookupPageID + Added Field 600..620

    Caption = 'POS Tax Amount Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Tax Line List";
    LookupPageID = "NPR POS Tax Line List";

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(4; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(5; "Tax Jurisdiction Code"; Code[10])
        {
            Caption = 'Tax Jurisdiction Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Jurisdiction";
        }
        field(8; "VAT Identifier"; Code[10])
        {
            Caption = 'Tax Identifier';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Tax Calculation Type"; Option)
        {
            Caption = 'VAT Calculation Type';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(10; "Tax Group Code"; Code[10])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Tax Group";
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(12; Modified; Boolean)
        {
            Caption = 'Modified';
            DataClassification = CustomerContent;
        }
        field(13; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
            DataClassification = CustomerContent;
        }
        field(14; "Calculated Tax Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Calculated Tax Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; "Tax Difference"; Decimal)
        {
            Caption = 'Tax Difference';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(16; "Tax Type"; Option)
        {
            Caption = 'Tax Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sales and Use Tax,Excise Tax,Sales Tax Only,Use Tax Only';
            OptionMembers = "Sales and Use Tax","Excise Tax","Sales Tax Only","Use Tax Only";
        }
        field(17; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
        }
        field(20; "Tax Area Code for Key"; Code[20])
        {
            Caption = 'Tax Area Code for Key';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(25; "Invoice Discount Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(26; "Inv. Disc. Base Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Inv. Disc. Base Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(31; "Tax %"; Decimal)
        {
            Caption = 'Tax %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(32; "Tax Base Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Tax Base Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(33; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                // TESTFIELD("Tax %");
                // TESTFIELD("Tax Base Amount");
                // IF "Tax Amount" / "Tax Base Amount" < 0 THEN
                //  ERROR(Text002,FIELDCAPTION("Tax Amount"));
                // "Tax Difference" := "Tax Difference" + "Tax Amount" - xRec."Tax Amount";
            end;
        }
        field(34; "Amount Including Tax"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Including Tax';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(35; "Line Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(600; "Entry Date"; Date)
        {
            CalcFormula = Lookup ("NPR POS Entry"."Entry Date" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Entry Date';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(610; "Starting Time"; Time)
        {
            CalcFormula = Lookup ("NPR POS Entry"."Starting Time" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Starting Time';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(620; "Ending Time"; Time)
        {
            CalcFormula = Lookup ("NPR POS Entry"."Ending Time" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Ending Time';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10010; "Expense/Capitalize"; Boolean)
        {
            Caption = 'Expense/Capitalize';
            DataClassification = CustomerContent;
        }
        field(10020; "Print Order"; Integer)
        {
            Caption = 'Print Order';
            DataClassification = CustomerContent;
        }
        field(10030; "Print Description"; Text[50])
        {
            Caption = 'Print Description';
            DataClassification = CustomerContent;
        }
        field(10040; "Calculation Order"; Integer)
        {
            Caption = 'Calculation Order';
            DataClassification = CustomerContent;
        }
        field(10041; "Round Tax"; Option)
        {
            Caption = 'Round Tax';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'To Nearest,Up,Down';
            OptionMembers = "To Nearest",Up,Down;
        }
        field(10042; "Is Report-to Jurisdiction"; Boolean)
        {
            Caption = 'Is Report-to Jurisdiction';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10043; Positive; Boolean)
        {
            Caption = 'Positive';
            DataClassification = CustomerContent;
        }
        field(10044; "Tax Base Amount FCY"; Decimal)
        {
            Caption = 'Tax Base Amount FCY';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Entry No.", "Tax Area Code for Key", "Tax Jurisdiction Code", "VAT Identifier", "Tax %", "Tax Group Code", "Expense/Capitalize", "Tax Type", "Use Tax", Positive)
        {
        }
        key(Key2; "Print Order", "Tax Area Code for Key", "Tax Jurisdiction Code")
        {
        }
        key(Key3; "Tax Area Code for Key", "Tax Group Code", "Tax Type", "Calculation Order")
        {
        }
    }

    fieldgroups
    {
    }
}

