page 6151586 "NPR Event Exch. Int. E-Mails"
{
    Extensible = False;
    Caption = 'Event Exch. Int. E-Mails';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Event Exch. Int. E-Mail";
    SourceTableView = sorting("Search E-Mail");
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("E-Mail"; Rec."E-Mail")
                {

                    ToolTip = 'Specifies the value of the E-Mail field';
                    ApplicationArea = NPRRetail;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempEmailAccount: Record "Email Account" temporary;
                    begin
                        if Page.RunModal(Page::"Email Accounts", TempEmailAccount) = ACTION::LookupOK then
                            Rec.Validate("E-Mail", TempEmailAccount."Email Address");
                    end;
                }
                field(TokenSet; Rec."Access Token".HasValue())
                {

                    Caption = 'Token Set';
                    Editable = false;
                    ToolTip = 'Specifies if access token for Access token is set for selected record.';
                    ApplicationArea = NPRRetail;
                }
                field("Default Organizer E-Mail"; Rec."Default Organizer E-Mail")
                {

                    ToolTip = 'Specifies the value of the Default Organizer E-Mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Time Zone No."; Rec."Time Zone No.")
                {

                    ToolTip = 'Specifies the value of the Time Zone No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Time Zone Display Name"; Rec."Time Zone Display Name")
                {

                    ToolTip = 'Specifies the value of the Time Zone Display Name field';
                    ApplicationArea = NPRRetail;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {

            action("Test Server Connection")
            {
                Caption = 'Test Server Connection';
                Image = Link;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Test Server Connection action which will query GraphAPI with Access token from selected record and return Email address of registered user.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    GraphAPIManagement: Codeunit "NPR Graph API Management";
                begin
                    GraphAPIManagement.TestConnection(Rec);
                end;
            }
            action(GetAccessToken)
            {
                Caption = 'Get Access Token';
                Image = DataEntry;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Get Access Token action which will lead to login page to your account to acquire Access token for GraphAPI.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    GraphAPIManagement: Codeunit "NPR Graph API Management";
                begin
                    GraphAPIManagement.GetAccessToken(Rec);
                end;
            }
            action(GraphAPISetup)
            {
                Caption = 'GraphAPI Setup';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "NPR GraphAPI Setup";

                ToolTip = 'Executes the action GraphAPI Setup.';
                ApplicationArea = NPRRetail;
            }

        }
    }
}

