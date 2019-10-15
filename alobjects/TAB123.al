tableextension 6014413 tableextension6014413 extends "Purch. Inv. Line" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields 6014602..6014604
    // VRT1.00/JDH/20150304 CASE 201022 Added Variety Fields for grouping
    // NPR5.38.01/JKL/20180206/ Case 289017 added field 6151051
    fields
    {
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
        field(6014604;Label;Boolean)
        {
            Caption = 'Label';
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
        field(6151051;"Retail Replenisment No.";Integer)
        {
            Caption = 'Retail Replenisment No.';
            Description = 'NPR5.38.01';
        }
    }
}

