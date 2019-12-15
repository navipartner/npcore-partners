table 6150630 "POS Workshift Tax Checkpoint"
{
    // NPR5.40/TSA /20180227 CASE 282251 Initial Version
    // NPR5.48/JDH /20181109 CASE 334163 Added captions to fields and object
    // NPR5.49/TSA /20190315 CASE 348458 Added "Consolidated With Entry No."

    Caption = 'POS Workshift Tax Checkpoint';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(4;"Tax Area Code";Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(8;"VAT Identifier";Code[10])
        {
            Caption = 'Tax Identifier';
            Editable = false;
        }
        field(9;"Tax Calculation Type";Option)
        {
            Caption = 'VAT Calculation Type';
            Editable = false;
            OptionCaption = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(10;"Consolidated With Entry No.";Integer)
        {
            Caption = 'Consolidated With Entry No.';
        }
        field(16;"Tax Type";Option)
        {
            Caption = 'Tax Type';
            OptionCaption = 'Sales and Use Tax,Excise Tax,Sales Tax Only,Use Tax Only';
            OptionMembers = "Sales and Use Tax","Excise Tax","Sales Tax Only","Use Tax Only";
        }
        field(31;"Tax %";Decimal)
        {
            Caption = 'Tax %';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(32;"Tax Base Amount";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Tax Base Amount';
            Editable = false;
        }
        field(33;"Tax Amount";Decimal)
        {
            Caption = 'Tax Amount';

            trigger OnValidate()
            begin
                // TESTFIELD("Tax %");
                // TESTFIELD("Tax Base Amount");
                // IF "Tax Amount" / "Tax Base Amount" < 0 THEN
                //  ERROR(Text002,FIELDCAPTION("Tax Amount"));
                // "Tax Difference" := "Tax Difference" + "Tax Amount" - xRec."Tax Amount";
            end;
        }
        field(34;"Amount Including Tax";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Including Tax';
            Editable = false;
        }
        field(35;"Line Amount";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Line Amount';
            Editable = false;
        }
        field(200;"Workshift Checkpoint Entry No.";Integer)
        {
            Caption = 'Workshift Checkpoint Entry No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Workshift Checkpoint Entry No.","Tax Area Code","VAT Identifier","Tax Calculation Type")
        {
        }
    }

    fieldgroups
    {
    }
}

