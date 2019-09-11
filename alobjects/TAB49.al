tableextension 50037 tableextension50037 extends "Invoice Post. Buffer" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added fields 6014400..6014401
    // NPR4.18/BR/20160108 CASE 231276 Added field "Purchase / Sales lineno." at the end of Primary Key
    // NPR5.25/JDH/20160711 CASE 241848 Removed "Purchase / Sales lineno." in the primary key (back to std) - it wasnt used correct any more
    fields
    {
        field(6014400;"Purchase / Sales lineno.";Integer)
        {
            Caption = 'Purchase / Sales lineno.';
            Description = 'NPR7.100.000';
        }
        field(6014401;Description;Text[50])
        {
            Caption = 'Description';
            Description = 'NPR7.100.000';
        }
    }
}

