page 6059885 "NPR TM Ticket BOM Part"
{
    Extensible = False;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR TM Ticket Admission BOM";
    CardPageId = "NPR TM Ticket BOM Card";
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
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the code that is added to the value in the Item No. column to determine the ticket type (e.g., tickets for children/adults/seniors). Microsoft only supports one dimension of variants.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies useful information about the ticket, that can be included on the printed ticket.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Default; Rec.Default)
                {
                    ToolTip = 'Specifies the default admission when multiple admissions are created for the ticket.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(DeferRevenue; Rec.DeferRevenue)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies if the revenue should be deferred until this admission is admitted or ticket has expired.';
                }
                field("Admission Entry Validation"; Rec."Admission Entry Validation")
                {
                    ToolTip = 'Determines how many times the ticket can be validated when admitting entry.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Duration Formula"; Rec."Duration Formula")
                {
                    ToolTip = 'Determines the period during which the ticket is valid.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Max No. Of Entries"; Rec."Max No. Of Entries")
                {
                    ToolTip = 'Determines the maximum number of entries to an admission that can be made before the ticket becomes invalid.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Notification Profile Code"; Rec."Notification Profile Code")
                {
                    ToolTip = 'Specifies which events will trigger notifications to be sent to the ticket holder. This option is useful for CRM purposes.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Sales From Date"; Rec."Sales From Date")
                {
                    ToolTip = 'Specifies date from which the ticket can be purchased.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Sales Until Date"; Rec."Sales Until Date")
                {
                    ToolTip = 'Specifies the date until which the ticket can be purchased.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("POS Sale May Exceed Capacity"; Rec."POS Sale May Exceed Capacity")
                {
                    ToolTip = 'Specifies whether the capacity may be exceed when ticket is sold in POS.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Percentage of Adm. Capacity"; Rec."Percentage of Adm. Capacity")
                {
                    ToolTip = 'Determines a percentage of maximum admission capacity for the provided Item No.. This is a useful option when there are several types of tickets sold for the same admission.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            Action(NavigateAdmissions)
            {
                ToolTip = 'Navigate to Admission Setup';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Scope = Repeater;
                Caption = 'Admission';
                Image = WorkCenter;
                RunObject = Page "NPR TM Admission Card";
                RunPageLink = "Admission Code" = field("Admission Code");
            }
            Action(NavigateAdmissionsSchedules)
            {
                ToolTip = 'Navigate to Admission Schedules';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Scope = Repeater;
                Caption = 'Admission Schedules';
                Image = CalendarWorkcenter;
                RunObject = Page "NPR TM Admis. Schedule Lines";
                RunPageLink = "Admission Code" = field("Admission Code");
            }
            Action(NavigateAdmissionsSchedulesEntries)
            {
                ToolTip = 'Navigate to Admission Schedule Entries';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Scope = Repeater;
                Caption = 'Schedule Entries';
                Image = WorkCenterLoad;
                RunObject = Page "NPR TM Admis. Schedule Entry";
                RunPageLink = "Admission Code" = field("Admission Code");
            }
        }
    }
}