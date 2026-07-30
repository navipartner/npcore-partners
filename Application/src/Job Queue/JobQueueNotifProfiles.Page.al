page 6059842 "NPR Job Queue Notif. Profiles"
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'Job Queue Notif. Profiles';
    AdditionalSearchTerms = 'Job Queue Notification Profile';
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
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description for the notification profile.';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the table number notification profile is to be used for.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Send E-mail"; Rec."Send E-mail")
                {
                    ToolTip = 'Specifies whether a notification e-mail should be sent to a responsible person. The emails are sent using e-mail templates.';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail Template Code"; Rec."E-mail Template Code")
                {
                    Visible = not _NewEmailExperienceEnabled;
                    ToolTip = 'Specifies a template, which will be used for creation and sending notification e-mails.';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail Template Id"; Rec."E-mail Template Id")
                {
                    Visible = _NewEmailExperienceEnabled;
                    ToolTip = 'Specifies the NP Email template, which will be used for creation and sending notification e-mails.';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ShowMandatory = _NewEmailExperienceEnabled;
                    ToolTip = 'Specifies an e-mail address notification e-mails are to be sent to. When the legacy e-mail system is active you can leave this blank to use the default address defined on the e-mail template.';
                    ApplicationArea = NPRRetail;
                }
                field("Send Sms"; Rec."Send Sms")
                {
                    ToolTip = 'Specifies whether a notification SMS should be sent to a responsible person. The messages are sent using SMS templates.';
                    ApplicationArea = NPRRetail;
                }
                field("SMS Template Code"; Rec."SMS Template Code")
                {
                    ToolTip = 'Specifies a template, which will be used for creation and sending notification SMS messages.';
                    ApplicationArea = NPRRetail;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies a phone number notification SMS messages are to be sent to.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        _NewEmailExperienceEnabled := NewEmailExperienceFeature.IsFeatureEnabled();
    end;

    var
        _NewEmailExperienceEnabled: Boolean;
}