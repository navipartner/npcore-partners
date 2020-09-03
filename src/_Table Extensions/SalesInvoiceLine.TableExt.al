tableextension 6014406 "NPR Sales Invoice Line" extends "Sales Invoice Line"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields 6014408..6014604
    // VRT1.00/JDH/20150304 CASE 201022 Added Variety Fields for grouping
    fields
    {
        field(6014408; "NPR Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            Description = 'NPR7.100.000';
        }
        field(6014409; "NPR Special Price"; Decimal)
        {
            Caption = 'Special Price';
            Description = 'NPR7.100.000';
        }
        field(6014415; "NPR Accessory"; Boolean)
        {
            Caption = 'Accessory';
            Description = 'NPR7.100.000';
        }
        field(6014416; "NPR Belongs to Item"; Code[20])
        {
            Caption = 'Belongs to Item';
            Description = 'NPR7.100.000';
        }
        field(6014417; "NPR Belongs to Line No."; Integer)
        {
            Caption = 'Belongs to Line No.';
            Description = 'NPR7.100.000';
        }
        field(6014602; "NPR Color"; Code[20])
        {
            Caption = 'Color';
            Description = 'NPR7.100.000';
        }
        field(6014603; "NPR Size"; Code[10])
        {
            Caption = 'Size';
            Description = 'NPR7.100.000';
        }
        field(6014604; "NPR Serial No. not Created"; Code[30])
        {
            Caption = 'Serial No. not Created';
            Description = 'NPR7.100.000';
        }
        field(6059970; "NPR Is Master"; Boolean)
        {
            Caption = 'Is Master';
            Description = 'VRT1.00';
        }
        field(6059971; "NPR Master Line No."; Integer)
        {
            Caption = 'Master Line No.';
            Description = 'VRT1.00';
        }
    }
}

