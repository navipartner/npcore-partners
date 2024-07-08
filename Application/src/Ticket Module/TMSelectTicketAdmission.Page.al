page 6059889 "NPR TM Select Ticket Admission"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR TM Ticket Admission BOM";
    Editable = false;
    Extensible = false;
    Caption = 'Select Ticket Admission';
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Admission Code"; Rec."Admission Code")
                {
                    ToolTip = 'Specifies the type of admission that the ticket can be used for. Tickets offer different levels of clearance, and they may allow access to multiple sites (e.g., dungeon and treasury tours in a castle).';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Description"; Rec."Admission Description")
                {
                    ToolTip = 'Specifies useful information about the admission that can be included on a printed ticket.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
            }
        }
    }
}
