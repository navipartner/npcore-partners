tableextension 6014433 "NPR Sales Line" extends "Sales Line"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    // NPR70.00.01.00/MH/20150216  CASE 204110 Removed NaviShop References (WS).
    // VRT1.00/JDH/20150304 CASE 201022 Added Variety Fields for grouping
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR5.22/TJ/20160407 CASE 238601 Removing unused variables
    fields
    {
        field(6014404; "NPR Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List","Photo work",Rounding,Combination,Customer;
        }
        field(6014405; "NPR Discount Code"; Code[30])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;
        }
        field(6014406; "NPR Part of product line"; Code[10])
        {
            Caption = 'Part of product line';
            DataClassification = CustomerContent;
        }
        field(6014407; "NPR Internal"; Boolean)
        {
            Caption = 'Internal';
            DataClassification = CustomerContent;
        }
        field(6014408; "NPR Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(6014409; "NPR Special Price"; Decimal)
        {
            Caption = 'Special Price';
            DataClassification = CustomerContent;
        }
        field(6014410; "NPR Color"; Code[20])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
        }
        field(6014411; "NPR Size"; Code[20])
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
        }
        field(6014412; "NPR Serial No. not Created"; Code[30])
        {
            Caption = 'Serial No. Not Created';
            DataClassification = CustomerContent;
        }
        field(6014413; "NPR Hide Line"; Boolean)
        {
            Caption = 'Hide Line';
            DataClassification = CustomerContent;
        }
        field(6014414; "NPR Main Line"; Boolean)
        {
            Caption = 'Main Line';
            DataClassification = CustomerContent;
        }
        field(6014415; "NPR Accessory"; Boolean)
        {
            Caption = 'Accessory';
            DataClassification = CustomerContent;
        }
        field(6014416; "NPR Belongs to Item"; Code[20])
        {
            Caption = 'Belongs to Item';
            DataClassification = CustomerContent;
        }
        field(6014417; "NPR Belongs to Line No."; Integer)
        {
            Caption = 'Belongs to Line No.';
            DataClassification = CustomerContent;
        }
        field(6014418; "NPR Belongs to Item Group"; Code[10])
        {
            Caption = 'Belongs to Item Group';
            DataClassification = CustomerContent;
        }
        field(6014419; "NPR Belongs 2 Item Disc.Group"; Code[10])
        {
            Caption = 'Belongs to Item Disc. Group';
            DataClassification = CustomerContent;
        }
        field(6014420; "NPR MR Anvendt antal"; Decimal)
        {
            Caption = 'MR Used Amount';
            DataClassification = CustomerContent;
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
    }
}

