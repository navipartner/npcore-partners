pageextension 6014426 "NPR Report Selections" extends "Report Selection - Sales"
{
    layout
    {
        addafter("Email Body Layout Description")
        {
            field("NPR Responsibility Center"; Rec."NPR Responsibility Center")
            {
                ToolTip = 'Specifies the code of the responsibility center, such as a distribution hub, that is associated with the involved user, company, customer, or vendor.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}
