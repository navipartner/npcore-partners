pageextension 6014418 "NPR VAT Bus. Posting Groups" extends "VAT Business Posting Groups"
{
    layout
    {
        addafter(Description)
        {
            field("NPR Restricted on POS"; Rec."NPR Restricted on POS")
            {
                ToolTip = 'Specifies whether the group usage is restricted on POS. If the option is activated, the group by default will not be copied to POS sales on customer selection.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}