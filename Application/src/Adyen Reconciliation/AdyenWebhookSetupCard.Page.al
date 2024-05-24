page 6184550 "NPR Adyen Webhook Setup Card"
{
    Extensible = false;
    Caption = 'Adyen Webhook Setup Card';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "NPR Adyen Webhook Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(ID; Rec.ID)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Webhook External ID.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        if Rec.ID <> '' then
                            _WebhookCreated := true;
                    end;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Webhook Type.';
                    Editable = not _WebhookCreated;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Webhook Description';
                }
                field("Web Service URL"; Rec."Web Service URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Web Service URL.';
                }
                field("Web Service Security"; Rec."Web Service Security")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Web Service Security Type.';
                }
                field("Web Service User"; Rec."Web Service User")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Web Service Basic Authentication User.';
                    Editable = Rec."Web Service Security" = Rec."Web Service Security"::"Basic authentication";
                    Enabled = Rec."Web Service Security" = Rec."Web Service Security"::"Basic authentication";
                }
                field("Web Service Password"; Rec."Web Service Password")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Web Service Basic Authentication Password.';
                    Editable = Rec."Web Service Security" = Rec."Web Service Security"::"Basic authentication";
                    Enabled = Rec."Web Service Security" = Rec."Web Service Security"::"Basic authentication";
                    ExtendedDatatype = Masked;
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Webhook is Active.';
                }
                field("Merchant Accounts Filter Type"; Rec."Merchant Accounts Filter Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Marchant Accounts Filter Type.';
                }
                field("Merchant Accounts Filter"; Rec."Merchant Accounts Filter")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Filter the Merchant Accounts list you want to setup a Webhook for.';
                    TableRelation = "NPR Adyen Merchant Account".Name;
                    AssistEdit = true;
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        MerchantAccounts: Page "NPR Adyen Merchant Accounts";
                        MerchantAccount: Record "NPR Adyen Merchant Account";
                    begin
                        MerchantAccounts.LookupMode := true;
                        if MerchantAccounts.RunModal() = Action::LookupOK then begin
                            MerchantAccounts.SetSelectionFilter(MerchantAccount);
                            Rec."Merchant Accounts Filter" := CopyStr(MerchantAccount.GetFilter(Name), 1, MaxStrLen(Rec."Merchant Accounts Filter"));
                            Rec.Modify();
                            CurrPage.Update();
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Set up a webhook")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Set up a webhook';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Setup;
                ToolTip = 'Running this action will create a Webhook in Adyen and retrieve its ID.';

                trigger OnAction()
                var
                    AdyenManagement: Codeunit "NPR Adyen Management";
                    WebhookSetUpSuccess: Label 'Successfully configured Webhook %1!';
                    WebhookSetUpError: Label 'Could not configure current Webhook! Please contact your Administrator!';
                begin
                    if Rec.ID = '' then begin
                        if AdyenManagement.CreateWebhook(Rec) then begin
                            CurrPage.Update();
                            Message(StrSubstNo(WebhookSetUpSuccess, Format(Rec.ID)));
                        end else
                            Error(WebhookSetUpError);
                    end;
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        xRec.Init();
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec.ID <> '' then
            _WebhookCreated := true;
    end;

    var
        _WebhookCreated: Boolean;
}
