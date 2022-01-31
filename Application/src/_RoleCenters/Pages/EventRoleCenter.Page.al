page 6060165 "NPR Event Role Center"
{
    Extensible = False;
    Caption = 'Event Role Center';
    PageType = RoleCenter;
    UsageCategory = None;
    layout
    {
        area(rolecenter)
        {
            group(Control6014401)
            {
                ShowCaption = false;
                part(Control6014402; "NPR Event Activities")
                {
                    ApplicationArea = NPRRetail;

                }
                part(Control6014413; "NPR Event Events by Attributes")
                {
                    ApplicationArea = NPRRetail;

                }
            }
            group(Control6014409)
            {
                ShowCaption = false;
                part(Control6014410; "NPR Event Next 10 Events")
                {
                    ApplicationArea = NPRRetail;

                }
                part(Control6014411; "NPR Event Notes")
                {
                    ApplicationArea = NPRRetail;

                }
                part(Control6014412; "NPR Event Resource Overview")
                {
                    ApplicationArea = NPRRetail;

                }
                systempart(Control6014417; MyNotes)
                {
                    ApplicationArea = NPRRetail;

                }
            }
        }
    }

    actions
    {
        area(embedding)
        {
            action(CustomerList)
            {
                Caption = 'Customer List';
                RunObject = Page "Customer List";

                ToolTip = 'Executes the Customer List action';
                ApplicationArea = NPRRetail;
            }
            action(ItemList)
            {
                Caption = 'Item List';
                RunObject = Page "Item List";

                ToolTip = 'Executes the Item List action';
                ApplicationArea = NPRRetail;
            }
            action(PlanningLines)
            {
                Caption = 'Planning Lines';
                RunObject = Page "NPR Event Planning Line List";

                ToolTip = 'Executes the Planning Lines action';
                ApplicationArea = NPRRetail;
            }
            action(ResourceList)
            {
                Caption = 'Resource List';
                RunObject = Page "Resource List";

                ToolTip = 'Executes the Resource List action';
                ApplicationArea = NPRRetail;
            }
            action(ExchIntEmails)
            {
                Caption = 'Exch. Int. E-mails';
                RunObject = Page "NPR Event Exch. Int. E-Mails";

                ToolTip = 'Executes the Exch. Int. E-mails action';
                ApplicationArea = NPRRetail;
            }
            action("Event Analysis")
            {
                Caption = 'Event Resource Avail.';
                Image = AnalysisView;
                RunObject = Page "NPR Event Res. Avail. Overview";

                ToolTip = 'Executes the Event Resource Availability Overview';
                ApplicationArea = NPRRetail;
            }

            action("Event Overview")
            {
                Caption = 'Event Overview';
                Image = AnalysisView;
                RunObject = report "NPR Event Overview";

                ToolTip = 'Executes the Event Overview';
                ApplicationArea = NPRRetail;
            }
        }
        area(Sections)
        {
            group(Setup)
            {
                Caption = 'Setup';

                action(ExchIntTemplates)
                {
                    Caption = 'Exch. Int. Templates';
                    RunObject = Page "NPR Event Exch. Int. Templates";

                    ToolTip = 'Executes the Exch. Int. Templates action';
                    ApplicationArea = NPRRetail;
                }
                action(AttributeTemplates)
                {
                    Caption = 'Attribute Templates';
                    RunObject = Page "NPR Event Attribute Templ.";

                    ToolTip = 'Executes the Attribute Templates action';
                    ApplicationArea = NPRRetail;
                }
                action(JobsSetup)
                {
                    Caption = 'Jobs Setup';
                    RunObject = Page "Jobs Setup";

                    ToolTip = 'Executes the Jobs Setup action';
                    ApplicationArea = NPRRetail;
                }

            }
        }
    }
}
