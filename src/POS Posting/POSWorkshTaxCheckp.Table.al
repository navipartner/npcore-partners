table 6150630 "NPR POS Worksh. Tax Checkp."
{
    // NPR5.40/TSA /20180227 CASE 282251 Initial Version
    // NPR5.48/JDH /20181109 CASE 334163 Added captions to fields and object
    // NPR5.49/TSA /20190315 CASE 348458 Added "Consolidated With Entry No."
    // NPR5.55/TSA /20200511 CASE 401889 Added Tax Jurisdiction Code, Tax Group Code
    // NPR5.55/JAKUBV/20200807  CASE 400098 Transport NPR5.55 - 31 July 2020

    Caption = 'POS Workshift Tax Checkpoint';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
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
        field(7; "Tax Group Code"; Code[10])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Tax Group";
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
        field(10; "Consolidated With Entry No."; Integer)
        {
            Caption = 'Consolidated With Entry No.';
            DataClassification = CustomerContent;
        }
        field(16; "Tax Type"; Option)
        {
            Caption = 'Tax Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sales and Use Tax,Excise Tax,Sales Tax Only,Use Tax Only';
            OptionMembers = "Sales and Use Tax","Excise Tax","Sales Tax Only","Use Tax Only";
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
        field(200; "Workshift Checkpoint Entry No."; Integer)
        {
            Caption = 'Workshift Checkpoint Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Workshift Checkpoint Entry No.", "Tax Area Code", "VAT Identifier", "Tax Calculation Type")
        {
        }
    }

    fieldgroups
    {
    }
}

