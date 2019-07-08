page 6151580 "Event Exch. Int. Template Card"
{
    // NPR5.36/TJ  /20170912 CASE 287800 New object
    // NPR5.43/NPKNAV/20180629  CASE 262079 Transport NPR5.43 - 29 June 2018

    Caption = 'Event Exch. Int. Template Card';
    PageType = Card;
    SourceTable = "Event Exch. Int. Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("E-mail Template Header Code";"E-mail Template Header Code")
                {
                }
                field("Template For";"Template For")
                {
                }
                field("Exch. Item Type";"Exch. Item Type")
                {
                }
            }
            group("E-mail")
            {
                Caption = 'E-mail';
                Visible = "Exch. Item Type" = "Exch. Item Type"::"E-Mail";
                field("Ticket URL Placeholder(E-Mail)";"Ticket URL Placeholder(E-Mail)")
                {
                    Caption = 'Ticket URL Placeholder';
                }
            }
            group(Calendar)
            {
                Caption = 'Calendar';
                Visible = "Exch. Item Type" <> "Exch. Item Type"::"E-Mail";
                field("Include Comments (Calendar)";"Include Comments (Calendar)")
                {
                    Caption = 'Include Comments';
                }
                field("Conf. Color Categ. (Calendar)";"Conf. Color Categ. (Calendar)")
                {
                    Caption = 'Confirmed Color Category';
                }
                field("Reminder Enabled (Calendar)";"Reminder Enabled (Calendar)")
                {
                    Caption = 'Reminder Enabled';
                }
                field("Reminder (Minutes) (Calendar)";"Reminder (Minutes) (Calendar)")
                {
                    Caption = 'Reminder (Minutes)';
                }
                group(Appointment)
                {
                    Caption = 'Appointment';
                    Visible = "Exch. Item Type" = "Exch. Item Type"::Appointment;
                    field("Lasts Whole Day (Appointment)";"Lasts Whole Day (Appointment)")
                    {
                        Caption = 'Lasts Whole Day';
                    }
                    field("First Day Only (Appointment)";"First Day Only (Appointment)")
                    {
                        Caption = 'First Day Only';
                        Enabled = "Lasts Whole Day (Appointment)";
                    }
                }
            }
        }
    }

    actions
    {
    }
}

