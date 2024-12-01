page 6184828 "NPR MM Recurring Payments"
{
    Extensible = False;
    Caption = 'Recurring Payments';
    CardPageId = "NPR MM Recur. Payment Setup";
    PageType = List;
    Editable = false;
    UsageCategory = Administration;
    SourceTable = "NPR MM Recur. Paym. Setup";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this recurring payment.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the recurring payment.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }
}
