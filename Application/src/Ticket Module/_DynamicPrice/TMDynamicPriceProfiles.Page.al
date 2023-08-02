page 6059865 "NPR TM Dynamic Price Profiles"
{
    Extensible = false;
    PageType = List;
    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
    UsageCategory = Administration;
    SourceTable = "NPR TM Dynamic Price Profile";
    Caption = 'Ticket Price Profiles';
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/how-to/create_price_profile/';
    CardPageId = "NPR TM Dynamic Price Profile";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Profile Code"; Rec.ProfileCode)
                {
                    ToolTip = 'Specifies the value of the Profile Code field.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a short description of the intention of this price profile.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
            }
        }
    }
}