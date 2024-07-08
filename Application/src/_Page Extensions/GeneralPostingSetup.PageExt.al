pageextension 6014515 "NPR GeneralPostingSetup" extends "General Posting Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR NPR_AchievedRevenueTicketAcc"; Rec.NPR_AchievedRevenueTicketAcc)
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the Achieved Revenue (Ticketing) Account field.';
            }
        }
    }
}