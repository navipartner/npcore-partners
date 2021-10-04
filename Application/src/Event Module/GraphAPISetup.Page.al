page 6014666 "NPR GraphAPI Setup"
{

    Caption = 'GraphAPI Setup';
    PageType = Card;
    SourceTable = "NPR GraphApi Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(AzureApp)
            {
                Caption = 'Azure App';
                field("Client Id"; Rec."Client Id")
                {
                    ToolTip = 'Specifies the value of the Client Id field.';
                    ApplicationArea = NPRRetail;
                }
                field("Client Secret"; Rec."Client Secret")
                {
                    ToolTip = 'Specifies the value of the Client Secret field.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(GraphAPI)
            {
                Caption = 'Graph API';
                field("Graph Event Url"; Rec."Graph Event Url")
                {
                    ToolTip = 'Specifies the value of the Graph Event Url field.';
                    ApplicationArea = NPRRetail;
                }
                field("Graph Me Url"; Rec."Graph Me Url")
                {
                    ToolTip = 'Specifies the value of the Graph Me Url field.';
                    ApplicationArea = NPRRetail;
                }
                field("OAuth Authority Url"; Rec."OAuth Authority Url")
                {
                    ToolTip = 'Specifies the value of the OAuth Authority Url field.';
                    ApplicationArea = NPRRetail;
                }
                field("OAuth Token Url"; Rec."OAuth Token Url")
                {
                    ToolTip = 'Specifies the value of the OAuth Token Url field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        WizardNotification: Notification;
        SetupNotFoundLbl: Label 'GraphAPI Setup not found.';
        RunWizardQst: Label 'Run GraphAPI Wizard now.';
    begin
        if not Rec.Get() then begin
            WizardNotification.Message(SetupNotFoundLbl);
            WizardNotification.Scope := NotificationScope::LocalScope;
            WizardNotification.AddAction(RunWizardQst, Codeunit::"NPR Graph API Management", 'RunGraphAPIWizard');
            WizardNotification.Send();
        end;

    end;

}
