tableextension 50009 tableextension50009 extends "Sales Cr.Memo Line" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields 6014408..6014604
    // VRT1.00/JDH/20150304 CASE 201022 Added Variety Fields for grouping
    fields
    {
        field(6014408;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            Description = 'NPR7.100.000';
        }
        field(6014409;"Special price";Decimal)
        {
            Caption = 'Special price';
            Description = 'NPR7.100.000';
        }
        field(6014602;Color;Code[20])
        {
            Caption = 'Color';
            Description = 'NPR7.100.000';
        }
        field(6014603;Size;Code[20])
        {
            Caption = 'Size';
            Description = 'NPR7.100.000';
        }
        field(6014604;"Serial No. not Created";Code[30])
        {
            Caption = 'Serial No. not Created';
            Description = 'NPR7.100.000';
        }
        field(6059970;"Is Master";Boolean)
        {
            Caption = 'Is Master';
            Description = 'VRT1.00';
        }
        field(6059971;"Master Line No.";Integer)
        {
            Caption = 'Master Line No.';
            Description = 'VRT1.00';
        }
    }
}

