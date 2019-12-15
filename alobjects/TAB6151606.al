table 6151606 "NpDc Ext. Coupon Buffer"
{
    // NPR5.51/MHA /20190724  CASE 343352 Object Created

    Caption = 'NpDc Ext. Coupon Buffer';

    fields
    {
        field(1;"Document No.";Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
            NotBlank = true;
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(15;"Reference No.";Text[30])
        {
            Caption = 'Reference No.';
        }
        field(20;"Coupon Type";Code[20])
        {
            Caption = 'Coupon Type';
        }
        field(25;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(35;"Starting Date";DateTime)
        {
            Caption = 'Starting Date';
        }
        field(40;"Ending Date";DateTime)
        {
            Caption = 'Ending Date';
        }
        field(45;Open;Boolean)
        {
            Caption = 'Open';
        }
        field(50;"Remaining Quantity";Decimal)
        {
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0:5;
        }
        field(55;"In-use Quantity";Integer)
        {
            Caption = 'In-use Quantity';
        }
    }

    keys
    {
        key(Key1;"Document No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

