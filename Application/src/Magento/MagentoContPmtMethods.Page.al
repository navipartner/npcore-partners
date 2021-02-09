page 6151441 "NPR Magento Cont.Pmt.Methods"
{
    Caption = 'Contact Payment Methods';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Contact Pmt.Meth.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Payment Method Code"; Rec."External Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Payment Method Code field';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
            }
        }
    }
}