tableextension 50007 tableextension50007 extends "Sales Invoice Line" 
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
        field(6014409;"Special Price";Decimal)
        {
            Caption = 'Special Price';
            Description = 'NPR7.100.000';
        }
        field(6014415;Accessory;Boolean)
        {
            Caption = 'Accessory';
            Description = 'NPR7.100.000';
        }
        field(6014416;"Belongs to Item";Code[20])
        {
            Caption = 'Belongs to Item';
            Description = 'NPR7.100.000';
        }
        field(6014417;"Belongs to Line No.";Integer)
        {
            Caption = 'Belongs to Line No.';
            Description = 'NPR7.100.000';
        }
        field(6014602;Color;Code[20])
        {
            Caption = 'Color';
            Description = 'NPR7.100.000';
        }
        field(6014603;Size;Code[10])
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

