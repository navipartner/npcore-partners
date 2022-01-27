page 6059842 "NPR Job Queue Notif. Profiles"
{
    Extensible = false;
    ApplicationArea = All;
    Caption = 'Job Queue Notif. Profiles';
    PageType = List;
    SourceTable = "NPR Job Queue Notif. Profile";
    UsageCategory = Administration;
    PopulateAllFields = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code for the notification profile.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description for the notification profile.';
                    ApplicationArea = All;
                }
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the table number notification profile is to be used for.';
                    ApplicationArea = All;
                }
                field("Send E-mail"; Rec."Send E-mail")
                {
                    ToolTip = 'Specifies whether a notification e-mail should be sent to a responsible person. The emails are sent using e-mail templates.';
                    ApplicationArea = All;
                }
                field("E-mail Template Code"; Rec."E-mail Template Code")
                {
                    ToolTip = 'Specifies a template, which will be used for creation and sending notification e-mails.';
                    ApplicationArea = All;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ToolTip = 'Specifies an e-mail address notification e-mails are to be sent to. Leave this field blank if you want to use the default address defined on the e-mail template.';
                    ApplicationArea = All;
                }
                field("Send Sms"; Rec."Send Sms")
                {
                    ToolTip = 'Specifies whether a notification SMS should be sent to a responsible person. The messages are sent using SMS templates.';
                    ApplicationArea = All;
                }
                field("SMS Template Code"; Rec."SMS Template Code")
                {
                    ToolTip = 'Specifies a template, which will be used for creation and sending notification SMS messages.';
                    ApplicationArea = All;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies a phone number notification SMS messages are to be sent to.';
                    ApplicationArea = All;
                }
            }
        }
    }
}