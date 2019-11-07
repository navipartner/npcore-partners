tableextension 6014431 tableextension6014431 extends "Item Ledger Entry" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields NPR7.100.000 6014401..6014401
    // NPR70.00.00.01/MH/20150212  CASE 199932 Removed Web Reference.
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR5.22/TJ/20160407 CASE 238601 Removed unused variables
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.30/TJ  /20170224 CASE 266866 Removed keys containing fields Color and Size
    //                                   Removed unused fields
    //                                   Renamed and recaptioned our fields to follow proper naming standards
    // NPR5.52/ZESO/20190930  CASE 349417 Added Table Relation to Fields Salesperson Code + Item Group No
    // NPR5.52/ZESO/20191010  CASE 371446 Added field Document Date and Time id 6014417
    fields
    {
        field(6014401;"Group Sale";Boolean)
        {
            Caption = 'Group Sale';
            Description = 'NPR7.100.000';
        }
        field(6014405;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            Description = 'NPR7.100.000';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Period,Mixed,"Multiple Unit","Salesperson Discount",Inventory,"Photo Work",Rounding,Combination,Customer;
        }
        field(6014406;"Discount Code";Code[30])
        {
            Caption = 'Discount Code';
            Description = 'NPR7.100.000';
        }
        field(6014407;"Item Group No.";Code[10])
        {
            Caption = 'Item Group No.';
            Description = 'NPR7.100.000';
            TableRelation = "Item Group";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6014408;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
            Description = 'NPR7.100.000';
            TableRelation = Vendor;
        }
        field(6014413;"Register Number";Code[20])
        {
            Caption = 'Cash Register No.';
            Description = 'NPR7.100.000';
        }
        field(6014414;"Salesperson Code";Code[20])
        {
            Caption = 'Salesperson Code';
            Description = 'NPR7.100.000';
            TableRelation = "Salesperson/Purchaser";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6014416;"Document Time";Time)
        {
            Caption = 'Document Time';
            Description = 'NPR7.100.000';
        }
        field(6014417;"Document Date and Time";DateTime)
        {
            Caption = 'Document Date and Time';
            Description = 'NPR5.52';
        }
    }
}