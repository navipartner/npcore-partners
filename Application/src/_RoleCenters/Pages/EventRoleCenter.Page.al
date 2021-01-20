page 6060165 "NPR Event Role Center"
{
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
                    ApplicationArea = All;
                }
                part(Control6014413; "NPR Event Events by Attributes")
                {
                    ApplicationArea = All;
                }
            }
            group(Control6014409)
            {
                ShowCaption = false;
                part(Control6014410; "NPR Event Next 10 Events")
                {
                    ApplicationArea = All;
                }
                part(Control6014411; "NPR Event Notes")
                {
                    ApplicationArea = All;
                }
                part(Control6014412; "NPR Event Resource Overview")
                {
                    ApplicationArea = All;
                }
                systempart(Control6014417; MyNotes)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(embedding)
        {
            action(EventList)
            {
                Caption = 'Event List';
                RunObject = Page "NPR Event List";
                ApplicationArea = All;
                ToolTip = 'Executes the Event List action';
            }
            action(CustomerList)
            {
                Caption = 'Customer List';
                RunObject = Page "Customer List";
                ApplicationArea = All;
                ToolTip = 'Executes the Customer List action';
            }
            action(PlanningLines)
            {
                Caption = 'Planning Lines';
                RunObject = Page "NPR Event Planning Line List";
                ApplicationArea = All;
                ToolTip = 'Executes the Planning Lines action';
            }
            action(ResourceList)
            {
                Caption = 'Resource List';
                RunObject = Page "Resource List";
                ApplicationArea = All;
                ToolTip = 'Executes the Resource List action';
            }
            action(AttributeTemplates)
            {
                Caption = 'Attribute Templates';
                RunObject = Page "NPR Event Attribute Templ.";
                ApplicationArea = All;
                ToolTip = 'Executes the Attribute Templates action';
            }
            action(ExchIntTemplates)
            {
                Caption = 'Exch. Int. Templates';
                RunObject = Page "NPR Event Exch. Int. Templates";
                ApplicationArea = All;
                ToolTip = 'Executes the Exch. Int. Templates action';
            }
            action(ExchIntEmails)
            {
                Caption = 'Exch. Int. E-mails';
                RunObject = Page "NPR Event Exch. Int. E-Mails";
                ApplicationArea = All;
                ToolTip = 'Executes the Exch. Int. E-mails action';
            }
        }
    }
}

