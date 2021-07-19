pageextension 6014410 "NPR Item Reference Entries" extends "Item Reference Entries"
{
    layout
    {
        addbefore("Discontinue Bar Code")
        {
            field("NPR Label Barcode"; Rec."NPR Label Barcode")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies that you want the program to use this barcode for label printing';
            }
        }
    }
}