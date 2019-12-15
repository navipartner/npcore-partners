table 6150629 "POS Tax Amount Line"
{
    // NPR5.36/NPKNAV/20171003  CASE 279552 Transport NPR5.36 - 3 October 2017
    // NPR5.48/BHR /20190122 CASE 341968 Increase length of field 10030 from text30 to text 50

    Caption = 'POS Tax Amount Line';

    fields
    {
        field(1;"POS Entry No.";Integer)
        {
            Caption = 'POS Entry No.';
            TableRelation = "POS Entry";
        }
        field(4;"Tax Area Code";Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(5;"Tax Jurisdiction Code";Code[10])
        {
            Caption = 'Tax Jurisdiction Code';
            TableRelation = "Tax Jurisdiction";
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
        field(10;"Tax Group Code";Code[10])
        {
            Caption = 'Tax Group Code';
            Editable = false;
            TableRelation = "Tax Group";
        }
        field(11;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(12;Modified;Boolean)
        {
            Caption = 'Modified';
        }
        field(13;"Use Tax";Boolean)
        {
            Caption = 'Use Tax';
        }
        field(14;"Calculated Tax Amount";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Calculated Tax Amount';
            Editable = false;
        }
        field(15;"Tax Difference";Decimal)
        {
            Caption = 'Tax Difference';
            Editable = false;
        }
        field(16;"Tax Type";Option)
        {
            Caption = 'Tax Type';
            OptionCaption = 'Sales and Use Tax,Excise Tax,Sales Tax Only,Use Tax Only';
            OptionMembers = "Sales and Use Tax","Excise Tax","Sales Tax Only","Use Tax Only";
        }
        field(17;"Tax Liable";Boolean)
        {
            Caption = 'Tax Liable';
        }
        field(20;"Tax Area Code for Key";Code[20])
        {
            Caption = 'Tax Area Code for Key';
            TableRelation = "Tax Area";
        }
        field(25;"Invoice Discount Amount";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
            Editable = false;
        }
        field(26;"Inv. Disc. Base Amount";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Inv. Disc. Base Amount';
            Editable = false;
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
        field(10010;"Expense/Capitalize";Boolean)
        {
            Caption = 'Expense/Capitalize';
        }
        field(10020;"Print Order";Integer)
        {
            Caption = 'Print Order';
        }
        field(10030;"Print Description";Text[50])
        {
            Caption = 'Print Description';
        }
        field(10040;"Calculation Order";Integer)
        {
            Caption = 'Calculation Order';
        }
        field(10041;"Round Tax";Option)
        {
            Caption = 'Round Tax';
            Editable = false;
            OptionCaption = 'To Nearest,Up,Down';
            OptionMembers = "To Nearest",Up,Down;
        }
        field(10042;"Is Report-to Jurisdiction";Boolean)
        {
            Caption = 'Is Report-to Jurisdiction';
            Editable = false;
        }
        field(10043;Positive;Boolean)
        {
            Caption = 'Positive';
        }
        field(10044;"Tax Base Amount FCY";Decimal)
        {
            Caption = 'Tax Base Amount FCY';
        }
    }

    keys
    {
        key(Key1;"POS Entry No.","Tax Area Code for Key","Tax Jurisdiction Code","VAT Identifier","Tax %","Tax Group Code","Expense/Capitalize","Tax Type","Use Tax",Positive)
        {
        }
        key(Key2;"Print Order","Tax Area Code for Key","Tax Jurisdiction Code")
        {
        }
        key(Key3;"Tax Area Code for Key","Tax Group Code","Tax Type","Calculation Order")
        {
        }
    }

    fieldgroups
    {
    }
}

