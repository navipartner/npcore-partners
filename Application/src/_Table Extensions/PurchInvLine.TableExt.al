tableextension 6014413 "NPR Purch. Inv. Line" extends "Purch. Inv. Line"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields 6014602..6014604
    // VRT1.00/JDH/20150304 CASE 201022 Added Variety Fields for grouping
    // NPR5.38.01/JKL/20180206/ Case 289017 added field 6151051
    fields
    {
        field(6014602; "NPR Color"; Code[20])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014603; "NPR Size"; Code[20])
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014604; "NPR Label"; Boolean)
        {
            Caption = 'Label';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6059970; "NPR Is Master"; Boolean)
        {
            Caption = 'Is Master';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6059971; "NPR Master Line No."; Integer)
        {
            Caption = 'Master Line No.';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
        }
        field(6151051; "NPR Retail Replenishment No."; Integer)
        {
            Caption = 'Retail Replenisment No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38.01';
        }
    }
}

