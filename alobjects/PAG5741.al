pageextension 6014457 pageextension6014457 extends "Transfer Order Subform" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    // NPR4.13/MMV/20150708 CASE 214173 Changed "Item No." to variable to handle barcode scanning OnValidate trigger.
    // NPR5.23/TS/20151021 CASE 214173 Removed Code related to release 4.13
    // NPR5.23/TS/20151021 CASE 214173 Added field Cross Reference No."
    // NPR5.23/TJ/20160411 CASE 238601 Cleaned unused variable Item from OnAfterGetRecord and retuend control ID of field ITem No. to default
    // NPR5.27/MMV /20161024 CASE 256178 Added support for retail prints.
    // NPR5.29/MMV /20161122 CASE 259110 Removed CurrPage.UPDATE() on Print Validate
    // NPR5.29/BHR /20161123 CASE 258047 Add field Description2
    // VRT1.20/JDH /20150304 CASE 201022 Variety Action Added to raise Event
    // NPR5.29/TJ  /20170117 CASE 262797 Removed unused function and functions used as separators
    // NPR5.30/TJ  /20170202 CASE 262533 Removed code, control, variables and functions used for label printing and moved to a subscriber
    // NPR5.41/JDH /20180418 CASE 309641 Added Field Vendor item No.
    layout
    {
        addafter("Item No.")
        {
            field("Cross-Reference No.";"Cross-Reference No.")
            {
            }
        }
        addafter("Variant Code")
        {
            field("Vendor Item No.";"Vendor Item No.")
            {
                Visible = false;
            }
        }
        addafter(Description)
        {
            field("Description 2";"Description 2")
            {
            }
        }
    }
    actions
    {
        addafter(Dimensions)
        {
            action(Variety)
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
            }
        }
    }
}

