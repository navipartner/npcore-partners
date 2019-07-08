table 6059996 "Scanner Service Setup"
{
    // NPR5.29/NPKNAV/20170127  CASE 252352 Transport NPR5.29 - 27 januar 2017
    // NPR5.48/JDH /20181109 CASE 334163 Added Object caption

    Caption = 'Scanner Service Setup';

    fields
    {
        field(1;"No.";Code[10])
        {
            Caption = 'No.';
        }
        field(11;"Log Request";Boolean)
        {
            Caption = 'Log Request';
        }
        field(12;"Stock-Take Config Code";Code[10])
        {
            Caption = 'Stock-Take Conf. Code';
            TableRelation = "Stock-Take Configuration".Code;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }
}

