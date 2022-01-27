page 6151441 "NPR Magento Cont.Pmt.Methods"
{
    Extensible = False;
    Caption = 'Contact Payment Methods';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Contact Pmt.Meth.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Payment Method Code"; Rec."External Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the External Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
