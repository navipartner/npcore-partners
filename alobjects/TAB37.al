tableextension 6014433 tableextension6014433 extends "Sales Line" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    // NPR70.00.01.00/MH/20150216  CASE 204110 Removed NaviShop References (WS).
    // VRT1.00/JDH/20150304 CASE 201022 Added Variety Fields for grouping
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR5.22/TJ/20160407 CASE 238601 Removing unused variables
    fields
    {
        field(6014404;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List","Photo work",Rounding,Combination,Customer;
        }
        field(6014405;"Discount Code";Code[30])
        {
            Caption = 'Discount Code';
        }
        field(6014406;"Part of product line";Code[10])
        {
            Caption = 'Part of product line';
        }
        field(6014407;Internal;Boolean)
        {
            Caption = 'Internal';
        }
        field(6014408;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
        }
        field(6014409;"Special Price";Decimal)
        {
            Caption = 'Special Price';
        }
        field(6014410;Color;Code[20])
        {
            Caption = 'Color';
        }
        field(6014411;Size;Code[20])
        {
            Caption = 'Size';
        }
        field(6014412;"Serial No. not Created";Code[30])
        {
            Caption = 'Serial No. Not Created';
        }
        field(6014413;"Hide Line";Boolean)
        {
            Caption = 'Hide Line';
        }
        field(6014414;"Main Line";Boolean)
        {
            Caption = 'Main Line';
        }
        field(6014415;Accessory;Boolean)
        {
            Caption = 'Accessory';
        }
        field(6014416;"Belongs to Item";Code[20])
        {
            Caption = 'Belongs to Item';
        }
        field(6014417;"Belongs to Line No.";Integer)
        {
            Caption = 'Belongs to Line No.';
        }
        field(6014418;"Belongs to Item Group";Code[10])
        {
            Caption = 'Belongs to Item Group';
        }
        field(6014419;"Belongs to Item Disc. Group";Code[10])
        {
            Caption = 'Belongs to Item Disc. Group';
        }
        field(6014420;"MR Anvendt antal";Decimal)
        {
            Caption = 'MR Used Amount';
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

