page 6014554 "Touch Screen - Sales Line Zoom"
{
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR4.14/BHR/20150812 CASE 220173 Set property of page InsertAllowed=no deleteAllowed=0
    // NPR5.36/TS  /20170906  CASE 288808 Page Type set to List
    // NPR5.37/TS  /20171024  CASE 294174 Reverted to Card

    Caption = 'Touch Screen - Sales Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Sale Line POS";

    layout
    {
        area(content)
        {
            group(Control6014400)
            {
                ShowCaption = false;
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field("Serial No.";"Serial No.")
                {
                }
                field("Serial No. not Created";"Serial No. not Created")
                {
                }
                field("Insurance Category";"Insurance Category")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Reference;Reference)
                {
                }
                field(Description;Description)
                {
                }
                field("Dimension Set ID";"Dimension Set ID")
                {
                    Editable = false;
                }
                field("Discount Type";"Discount Type")
                {
                    Editable = false;
                }
                field("Discount Code";"Discount Code")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

