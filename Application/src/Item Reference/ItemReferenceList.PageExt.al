pageextension 6014411 "NPR Item Reference List" extends "Item Reference List"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR Label Barcode"; Rec."NPR Label Barcode")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies that you want the program to use this barcode for label printing';
            }
        }
    }
}

