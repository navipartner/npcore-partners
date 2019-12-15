tableextension 6014450 tableextension6014450 extends "Purchase Price" 
{
    // VRT1.00/JDH/20170502 CASE 271133 Added Variety Fields for grouping
    // NPR5.31/NPKNAV/20170502  CASE 271133 Transport NPR5.31 - 2 May 2017
    fields
    {
        field(6059970;"Is Master";Boolean)
        {
            Caption = 'Is Master';
            Description = 'VRT1.00';
        }
        field(6059972;"Master Record Reference";Text[250])
        {
            Caption = 'Master Record Reference';
            Description = 'VRT1.00';
        }
    }
}

