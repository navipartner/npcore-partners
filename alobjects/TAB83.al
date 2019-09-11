tableextension 50052 tableextension50052 extends "Item Journal Line" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added fields 6014401..6014604
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.30/TJ  /20170224 CASE 266866 Removed unused fields
    //                                   Renamed and recaptioned our fields to follow proper naming standards
    // NPR5.36/JDH/20150304 CASE 201022 Added Variety Fields for grouping
    fields
    {
        field(6014401;"Group Sale";Boolean)
        {
            Caption = 'Group Sale';
            Description = 'NPR7.100.000';
        }
        field(6014404;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            Description = 'NPR7.100.000';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Period,Mixed,"Multiple Unit","Salesperson Discount",Inventory,"Photo Work",Rounding,Combination,Customer;
        }
        field(6014405;"Discount Code";Code[20])
        {
            Caption = 'Discount Code';
            Description = 'NPR7.100.000';
        }
        field(6014407;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
            Description = 'NPR7.100.000';
        }
        field(6014408;"Item Group No.";Code[10])
        {
            Caption = 'Item Group No.';
            Description = 'NPR7.100.000';
        }
        field(6014413;"Register Number";Code[20])
        {
            Caption = 'Cash Register No.';
            Description = 'NPR7.100.000';
        }
        field(6014414;"Document Time";Time)
        {
            Caption = 'Document Time';
            Description = 'NPR7.100.000';
        }
        field(6059970;"Is Master";Boolean)
        {
            Caption = 'Is Master';
            Description = 'VRT';
        }
        field(6059971;"Master Line No.";Integer)
        {
            Caption = 'Master Line No.';
            Description = 'VRT';
        }
    }
}

