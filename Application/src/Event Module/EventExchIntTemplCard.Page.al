page 6151580 "NPR Event Exch.Int.Templ. Card"
{
    Caption = 'Event Exch. Int. Template Card';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Event Exch. Int. Template";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail Template Header Code"; Rec."E-mail Template Header Code")
                {

                    ToolTip = 'Specifies the value of the E-Mail Template Header Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Template For"; Rec."Template For")
                {

                    ToolTip = 'Specifies the value of the Template For field';
                    ApplicationArea = NPRRetail;
                }
                field("Exch. Item Type"; Rec."Exch. Item Type")
                {

                    ToolTip = 'Specifies the value of the Exch. Item Type field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("E-mail")
            {
                Caption = 'E-mail';
                Visible = Rec."Exch. Item Type" = Rec."Exch. Item Type"::"E-Mail";
                field("Ticket URL Placeholder(E-Mail)"; Rec."Ticket URL Placeholder(E-Mail)")
                {

                    Caption = 'Ticket URL Placeholder';
                    ToolTip = 'Specifies the value of the Ticket URL Placeholder field';
                    ApplicationArea = NPRRetail;
                }
                group("Automatic Sending")
                {
                    Caption = 'Automatic Sending';
                    field("Auto. Send. Enabled (E-Mail)"; Rec."Auto. Send. Enabled (E-Mail)")
                    {

                        ToolTip = 'Specifies the value of the Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Auto.Send.Event Status(E-Mail)"; Rec."Auto.Send.Event Status(E-Mail)")
                    {

                        ToolTip = 'Specifies the value of the For Event Status field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Open E-mail dialog"; Rec."Open E-mail dialog")
                    {
                        ToolTip = 'Specifies the value of the Open E-mail dialog field.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(Calendar)
            {
                Caption = 'Calendar';
                Visible = Rec."Exch. Item Type" <> Rec."Exch. Item Type"::"E-Mail";
                field("Include Comments (Calendar)"; Rec."Include Comments (Calendar)")
                {

                    Caption = 'Include Comments';
                    ToolTip = 'Specifies the value of the Include Comments field';
                    ApplicationArea = NPRRetail;
                }
                field("Conf. Color Categ. (Calendar)"; Rec."Conf. Color Categ. (Calendar)")
                {

                    Caption = 'Confirmed Color Category';
                    ToolTip = 'Specifies the value of the Confirmed Color Category field';
                    ApplicationArea = NPRRetail;
                }
                field("Reminder Enabled (Calendar)"; Rec."Reminder Enabled (Calendar)")
                {

                    Caption = 'Reminder Enabled';
                    ToolTip = 'Specifies the value of the Reminder Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Reminder (Minutes) (Calendar)"; Rec."Reminder (Minutes) (Calendar)")
                {

                    Caption = 'Reminder (Minutes)';
                    ToolTip = 'Specifies the value of the Reminder (Minutes) field';
                    ApplicationArea = NPRRetail;
                }
                group(Appointment)
                {
                    Caption = 'Appointment';
                    Visible = Rec."Exch. Item Type" = Rec."Exch. Item Type"::Appointment;
                    field("Lasts Whole Day (Appointment)"; Rec."Lasts Whole Day (Appointment)")
                    {

                        Caption = 'Lasts Whole Day';
                        ToolTip = 'Specifies the value of the Lasts Whole Day field';
                        ApplicationArea = NPRRetail;
                    }
                    field("First Day Only (Appointment)"; Rec."First Day Only (Appointment)")
                    {

                        Caption = 'First Day Only';
                        Enabled = Rec."Lasts Whole Day (Appointment)";
                        ToolTip = 'Specifies the value of the First Day Only field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }
}

