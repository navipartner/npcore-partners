page 6059868 "NPR TM Dynamic Price Profile"
{
    Extensible = false;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR TM Dynamic Price Profile";
    Caption = 'Ticket Price Profile';
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/how-to/create_price_profile/';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(ProfileCode; Rec.ProfileCode)
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
            part(Rules; "NPR TM Dynamic Price Rules")
            {
                Caption = 'Rules';
                ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                SubPageLink = ProfileCode = field(ProfileCode);
                SubPageView = sorting(ProfileCode, LineNo);
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                Caption = 'Price Simulation';
                ToolTip = 'Show the price simulator view.';
                Image = Simulate;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    SimulatorPage: Page "NPR TM Price Profile Simulator";
                begin
                    SimulatorPage.Initialize(Rec.ProfileCode);
                    SimulatorPage.Run();
                end;
            }
        }
    }
}