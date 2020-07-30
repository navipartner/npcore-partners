page 6151243 "NP Retail Event Role Center"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.33/NPKNAV/20170630  CASE 277946 Transport NPR5.33 - 30 June 2017
    // NPR5.34/TJ  /20170728  CASE 277938 Added action Exch. Int. Templates
    // NPR5.38/TJ  /20171027  CASE 285194 Added action Exch. Int. E-mails
    // NPR5.38/TJ  /20171110  CASE 296146 Added system part MyNotes

    Caption = 'NP Retail Event Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {

            /* part(Control7; "Headline RC Order Processor")
             {
                 // ApplicationArea = Basic, Suite;
             }
         */
            part(Control6014402; "Event Activities")
            {
            }
            part(Control6014413; "Event Events by Attributes")
            {
            }


            part(Control6014410; "Event Next 10 Events")
            {
            }
            part(Control6014411; "Event Notes")
            {
            }
            part(Control6014412; "Event Resource Overview")
            {
            }
            systempart(Control6014417; MyNotes)
            {
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
                RunObject = Page "Event List";
            }
            action(CustomerList)
            {
                Caption = 'Customer List';
                RunObject = Page "Customer List";
            }
            action(PlanningLines)
            {
                Caption = 'Planning Lines';
                RunObject = Page "Event Planning Line List";
            }
            action(ResourceList)
            {
                Caption = 'Resource List';
                RunObject = Page "Resource List";
            }
            action(AttributeTemplates)
            {
                Caption = 'Attribute Templates';
                RunObject = Page "Event Attribute Templates";
            }
            action(ExchIntTemplates)
            {
                Caption = 'Exch. Int. Templates';
                RunObject = Page "Event Exch. Int. Templates";
            }
            action(ExchIntEmails)
            {
                Caption = 'Exch. Int. E-mails';
                RunObject = Page "Event Exch. Int. E-Mails";
            }
        }
    }
}

