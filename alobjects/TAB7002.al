tableextension 6014450 tableextension6014450 extends "Sales Price" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields 6059800, 6060000
    // VRT1.00/JDH/20150304 CASE 201022 Added Variety Fields for grouping
    fields
    {
        field(6059800;"Value ID";Integer)
        {
            Caption = 'Value ID';
            Description = 'NPR7.000.000';
        }
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
        field(6060000;"Price Without Vat";Decimal)
        {
            Caption = 'Price Without Vat';
            Description = 'Field needed so we can sync normal to web//NPR7.000.000';
        }
    }
}

