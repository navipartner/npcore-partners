pageextension 6014418 "NPR VAT Bus. Posting Groups" extends "VAT Business Posting Groups"
{
    layout
    {
        addafter(Description)
        {
            field("NPR Restricted on POS"; Rec."NPR Restricted on POS")
            {
                ToolTip = 'Specifies if the code is allowed in POS or not.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}