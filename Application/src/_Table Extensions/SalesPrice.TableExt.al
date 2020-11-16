tableextension 6014450 "NPR Sales Price" extends "Sales Price"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields 6059800, 6060000
    // VRT1.00/JDH/20150304 CASE 201022 Added Variety Fields for grouping
    fields
    {
        field(6059800; "NPR Value ID"; Integer)
        {
            Caption = 'Value ID';
            DataClassification = CustomerContent;
            Description = 'NPR7.000.000';
        }
        field(6059970; "NPR Is Master"; Boolean)
        {
            Caption = 'Is Master';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059972; "NPR Master Record Reference"; Text[250])
        {
            Caption = 'Master Record Reference';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6060000; "NPR Price Without Vat"; Decimal)
        {
            Caption = 'Price Without Vat';
            DataClassification = CustomerContent;
            Description = 'Field needed so we can sync normal to web//NPR7.000.000';
        }
    }
}

