page 6014666 "NPR GraphAPI Setup"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;

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

    actions
    {
        area(Processing)
        {
            action(SetDefaultsValues)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Set default values';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Setup;
                ToolTip = 'Action sets default values to Graph API setup.';

                trigger OnAction()
                var
                    GraphAPIManagement: Codeunit "NPR Graph API Management";
                begin
                    GraphAPIManagement.SetDefaultsValues(Rec);
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        WizardNotification: Notification;
        SetupNotFoundLbl: Label 'GraphAPI Setup not found. Run action Set default values to fetch default setup values.';
    begin
        if not Rec.Get() then begin
            WizardNotification.Message(SetupNotFoundLbl);
            WizardNotification.Scope := NotificationScope::LocalScope;
            WizardNotification.Send();
        end;
    end;

}
