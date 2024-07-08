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
                ToolTip = 'View or edit detailed information for the customers that you trade with. For each customer card you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';

                ApplicationArea = NPRRetail;
            }
            action(ItemList)
            {
                Caption = 'Item List';
                RunObject = Page "Item List";
                ToolTip = 'View or edit detailed information for the products that you trade in. The item card can be of type Inventory or Service to specify if the item is a physical unit or a labor time unit. Here you also define if items in inventory or on incoming orders are automatically reserved for outbound documents and whether order tracking links are created between demand and supply to reflect planning actions';

                ApplicationArea = NPRRetail;
            }
            action(PlanningLines)
            {
                Caption = 'Planning Lines';
                RunObject = Page "NPR Event Planning Line List";
                ToolTip = 'View detailed information for job lines like planning date, job number, task number, type, quantity etc.';

                ApplicationArea = NPRRetail;
            }
            action(ResourceList)
            {
                Caption = 'Resource List';
                RunObject = Page "Resource List";
                ToolTip = 'View or edit detailed information for all resources and related information.';

                ApplicationArea = NPRRetail;
            }
            action(ExchIntEmails)
            {
                Caption = 'Exch. Int. E-mails';
                RunObject = Page "NPR Event Exch. Int. E-Mails";
                ToolTip = 'View or edit detailed information for all email addresses that you specify for an exchange integration.';

                ApplicationArea = NPRRetail;
            }
            action("Event Analysis")
            {
                Caption = 'Event Resource Avail.';
                Image = AnalysisView;
                RunObject = Page "NPR Event Res. Avail. Overview";
                ToolTip = 'View detailed information about resource availability after specifying the time interval.';

                ApplicationArea = NPRRetail;
            }

            action("Event Overview")
            {
                Caption = 'Event Overview';
                Image = AnalysisView;
                RunObject = report "NPR Event Overview";
                ToolTip = 'Executes the report Event Overview where you can filter data for time interval and type.';

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
                    ToolTip = 'View and edit detailed information for the templates of event exchange integration whether sending e-mail, creating an appointment or a meeting request.';

                    ApplicationArea = NPRRetail;
                }
                action(AttributeTemplates)
                {
                    Caption = 'Attribute Templates';
                    RunObject = Page "NPR Event Attribute Templ.";
                    ToolTip = 'View or edit detailed information for the attribute templates which serve as generic area to store different information about an event.';

                    ApplicationArea = NPRRetail;
                }
                action(JobsSetup)
                {
                    Caption = 'Jobs Setup';
                    RunObject = Page "Jobs Setup";
                    ToolTip = 'View detailed information about job setup regarding the events.';

                    ApplicationArea = NPRRetail;
                }

            }
        }
    }
}
