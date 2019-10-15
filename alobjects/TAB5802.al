tableextension 6014447 tableextension6014447 extends "Value Entry" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields NPR7.100.000
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.30/TJ  /20170222 CASE 266866 Removed unused fields
    //                                   Renamed and recaptioned our fields to follow proper naming standards
    // NPR5.43/ZESO/20182906 CASE 312575 Added field Item Category Code
    // NPR5.48/TJ  /20181115 CASE 330832 Increased Length of field Item Category Code from 10 to 20
    // NPR5.48/JDH /20181109 CASE 334163 Added caption to field Item Category Code
    // NPR5.48/TS  /20181203 CASE 338349 Item Category Code is 20
    // NPR5.50/ZESO/20190528 CASE 355450 Added SumIndexfields Invoiced Quantity,Sales Amount(Actual),Cost Amount (Actual) to Key
    //                                   Item Ledger Entry Type,Posting Date,Global Dimension 1 Code,Global Dimension 2 Code,Salespers./Purch. Code,Item Group No.,Item No.,Vendor No.,Source No.,Group Sale
    fields
    {
        field(6014401;"Group Sale";Boolean)
        {
            Caption = 'Group Sale';
            Description = 'NPR7.100.000';
        }
        field(6014407;"Item Group No.";Code[20])
        {
            Caption = 'Item Group No.';
            Description = 'NPR7.100.000';
        }
        field(6014408;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
            Description = 'NPR7.100.000';
            TableRelation = Vendor;
        }
        field(6014409;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            Description = 'NPR7.100.000';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Period,Mixed,"Multiple Unit","Salesperson Discount",Inventory,"Photo Work",Rounding,Combination,Customer;
        }
        field(6014410;"Discount Code";Code[30])
        {
            Caption = 'Discount Code';
            Description = 'NPR7.100.000';
        }
        field(6014413;"Register No.";Code[20])
        {
            Caption = 'Cash Register No.';
            Description = 'NPR7.100.000';
        }
        field(6014414;"Salesperson Code";Code[20])
        {
            Caption = 'Salesperson Code';
            Description = 'NPR7.100.000';
            TableRelation = "Salesperson/Purchaser";
        }
        field(6014415;"Item Category Code";Code[20])
        {
            Caption = 'Item Category Code';
            Description = 'NPR5.43,NPR5.48';
        }
    }
}

