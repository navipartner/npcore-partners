page 6151580 "NPR Event Exch.Int.Templ. Card"
{
    // NPR5.36/TJ  /20170912 CASE 287800 New object
    // NPR5.43/NPKNAV/20180629  CASE 262079 Transport NPR5.43 - 29 June 2018
    // NPR5.55/TJ  /20200129 CASE 374887 New fields "Auto. Send. Enabled (E-Mail)" and "Auto.Send.Event Status(E-Mail)" under new group "Automatic Sending"

    Caption = 'Event Exch. Int. Template Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("E-mail Template Header Code"; "E-mail Template Header Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail Template Header Code field';
                }
                field("Template For"; "Template For")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template For field';
                }
                field("Exch. Item Type"; "Exch. Item Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Exch. Item Type field';
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
                    ToolTip = 'Specifies the value of the Ticket URL Placeholder field';
                }
                group("Automatic Sending")
                {
                    Caption = 'Automatic Sending';
                    field("Auto. Send. Enabled (E-Mail)"; "Auto. Send. Enabled (E-Mail)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Enabled field';
                    }
                    field("Auto.Send.Event Status(E-Mail)"; "Auto.Send.Event Status(E-Mail)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the For Event Status field';
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
                    ToolTip = 'Specifies the value of the Include Comments field';
                }
                field("Conf. Color Categ. (Calendar)"; "Conf. Color Categ. (Calendar)")
                {
                    ApplicationArea = All;
                    Caption = 'Confirmed Color Category';
                    ToolTip = 'Specifies the value of the Confirmed Color Category field';
                }
                field("Reminder Enabled (Calendar)"; "Reminder Enabled (Calendar)")
                {
                    ApplicationArea = All;
                    Caption = 'Reminder Enabled';
                    ToolTip = 'Specifies the value of the Reminder Enabled field';
                }
                field("Reminder (Minutes) (Calendar)"; "Reminder (Minutes) (Calendar)")
                {
                    ApplicationArea = All;
                    Caption = 'Reminder (Minutes)';
                    ToolTip = 'Specifies the value of the Reminder (Minutes) field';
                }
                group(Appointment)
                {
                    Caption = 'Appointment';
                    Visible = "Exch. Item Type" = "Exch. Item Type"::Appointment;
                    field("Lasts Whole Day (Appointment)"; "Lasts Whole Day (Appointment)")
                    {
                        ApplicationArea = All;
                        Caption = 'Lasts Whole Day';
                        ToolTip = 'Specifies the value of the Lasts Whole Day field';
                    }
                    field("First Day Only (Appointment)"; "First Day Only (Appointment)")
                    {
                        ApplicationArea = All;
                        Caption = 'First Day Only';
                        Enabled = "Lasts Whole Day (Appointment)";
                        ToolTip = 'Specifies the value of the First Day Only field';
                    }
                }
            }
        }
    }

    actions
    {
    }
}

