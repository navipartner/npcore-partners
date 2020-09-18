page 6151580 "NPR Event Exch.Int.Templ. Card"
{
    // NPR5.36/TJ  /20170912 CASE 287800 New object
    // NPR5.43/NPKNAV/20180629  CASE 262079 Transport NPR5.43 - 29 June 2018
    // NPR5.55/TJ  /20200129 CASE 374887 New fields "Auto. Send. Enabled (E-Mail)" and "Auto.Send.Event Status(E-Mail)" under new group "Automatic Sending"

    Caption = 'Event Exch. Int. Template Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Event Exch. Int. Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("E-mail Template Header Code"; "E-mail Template Header Code")
                {
                    ApplicationArea = All;
                }
                field("Template For"; "Template For")
                {
                    ApplicationArea = All;
                }
                field("Exch. Item Type"; "Exch. Item Type")
                {
                    ApplicationArea = All;
                }
            }
            group("E-mail")
            {
                Caption = 'E-mail';
                Visible = "Exch. Item Type" = "Exch. Item Type"::"E-Mail";
                field("Ticket URL Placeholder(E-Mail)"; "Ticket URL Placeholder(E-Mail)")
                {
                    ApplicationArea = All;
                    Caption = 'Ticket URL Placeholder';
                }
                group("Automatic Sending")
                {
                    Caption = 'Automatic Sending';
                    field("Auto. Send. Enabled (E-Mail)"; "Auto. Send. Enabled (E-Mail)")
                    {
                        ApplicationArea = All;
                    }
                    field("Auto.Send.Event Status(E-Mail)"; "Auto.Send.Event Status(E-Mail)")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Calendar)
            {
                Caption = 'Calendar';
                Visible = "Exch. Item Type" <> "Exch. Item Type"::"E-Mail";
                field("Include Comments (Calendar)"; "Include Comments (Calendar)")
                {
                    ApplicationArea = All;
                    Caption = 'Include Comments';
                }
                field("Conf. Color Categ. (Calendar)"; "Conf. Color Categ. (Calendar)")
                {
                    ApplicationArea = All;
                    Caption = 'Confirmed Color Category';
                }
                field("Reminder Enabled (Calendar)"; "Reminder Enabled (Calendar)")
                {
                    ApplicationArea = All;
                    Caption = 'Reminder Enabled';
                }
                field("Reminder (Minutes) (Calendar)"; "Reminder (Minutes) (Calendar)")
                {
                    ApplicationArea = All;
                    Caption = 'Reminder (Minutes)';
                }
                group(Appointment)
                {
                    Caption = 'Appointment';
                    Visible = "Exch. Item Type" = "Exch. Item Type"::Appointment;
                    field("Lasts Whole Day (Appointment)"; "Lasts Whole Day (Appointment)")
                    {
                        ApplicationArea = All;
                        Caption = 'Lasts Whole Day';
                    }
                    field("First Day Only (Appointment)"; "First Day Only (Appointment)")
                    {
                        ApplicationArea = All;
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

