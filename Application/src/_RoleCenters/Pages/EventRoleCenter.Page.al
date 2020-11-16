page 6060165 "NPR Event Role Center"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.33/NPKNAV/20170630  CASE 277946 Transport NPR5.33 - 30 June 2017
    // NPR5.34/TJ  /20170728  CASE 277938 Added action Exch. Int. Templates
    // NPR5.38/TJ  /20171027  CASE 285194 Added action Exch. Int. E-mails
    // NPR5.38/TJ  /20171110  CASE 296146 Added system part MyNotes

    Caption = 'Event Role Center';
    PageType = RoleCenter;
    UsageCategory = Administration;

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
            }
            action(CustomerList)
            {
                Caption = 'Customer List';
                RunObject = Page "Customer List";
                ApplicationArea = All;
            }
            action(PlanningLines)
            {
                Caption = 'Planning Lines';
                RunObject = Page "NPR Event Planning Line List";
                ApplicationArea = All;
            }
            action(ResourceList)
            {
                Caption = 'Resource List';
                RunObject = Page "Resource List";
                ApplicationArea = All;
            }
            action(AttributeTemplates)
            {
                Caption = 'Attribute Templates';
                RunObject = Page "NPR Event Attribute Templ.";
                ApplicationArea = All;
            }
            action(ExchIntTemplates)
            {
                Caption = 'Exch. Int. Templates';
                RunObject = Page "NPR Event Exch. Int. Templates";
                ApplicationArea = All;
            }
            action(ExchIntEmails)
            {
                Caption = 'Exch. Int. E-mails';
                RunObject = Page "NPR Event Exch. Int. E-Mails";
                ApplicationArea = All;
            }
        }
    }
}

