page 6151479 "NPR Vipps Mp Webhook List"
{
    PageType = List;
    Extensible = False;
    Caption = 'Vipps Mobilepay Webhooks';
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = False;
    SourceTable = "NPR Vipps Mp Webhook";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Webhook Reference"; Rec."Webhook Reference")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique reference for this webhook.';
#if NOT BC17
                    AboutTitle = 'Webhook Reference';
                    AboutText = 'Specifies the unique reference for this webhook.';
#endif

                }
                field("Merchant Serial Number"; Rec."Merchant Serial Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies which MSN the webhook is created for.';
#if NOT BC17
                    AboutTitle = 'Merchant Serial Number';
                    AboutText = 'Specifies which MSN the webhook is created for.';
#endif

                }
                field("Webhook Id"; Rec."Webhook Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Id of the webhook used in the Vipps Mobilepay backend.';
#if NOT BC17
                    AboutTitle = 'Webhook Id';
                    AboutText = 'Specifies the Id of the webhook used in the Vipps Mobilepay backend.';
#endif

                }
                field("Webhook Secret"; Rec."Webhook Secret")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the secret key used to validate webhooks. This is only sent on creation of webhook.';
#if NOT BC17
                    AboutTitle = 'Webhook Secret';
                    AboutText = 'Specifies the secret key used to validate webhooks. This is only sent on creation of webhook.';
#endif

                }
                field("Webhook Url"; Rec."Webhook Url")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Url endpoint Vipps Mobilepay is using to send webhooks.';
#if NOT BC17
                    AboutTitle = 'Webhook Url';
                    AboutText = 'Specifies the Url endpoint Vipps Mobilepay is using to send webhooks.';
#endif

                }
                field("AF Credential Id"; Rec."OnPrem AF Credential Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Credential Id, used for OnPrem solutions to authorize the sending of webhooks to BC.';
                    Visible = IsOnPrem;
#if NOT BC17
                    AboutTitle = 'Credential Id';
                    AboutText = 'Credential Id, used for OnPrem solutions to authorize the sending of webhooks to BC.';
#endif
                }

                field("AF Credential Key"; Rec."OnPrem AF Credential Key")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Credential Key, used for OnPrem solutions to authorize the sending of webhooks to BC.';
                    Visible = IsOnPrem;
#if NOT BC17
                    AboutTitle = 'Credential Key';
                    AboutText = 'Credential Key, used for OnPrem solutions to authorize the sending of webhooks to BC.';
#endif
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateNew)
            {
                ApplicationArea = NPRRetail;
                Image = Add;
                Caption = 'Create Webhook';
                Description = 'Creates a new webhook registration in Vipps Mobilepay and Bc. One Webhook pr MSN allowed.';
                Tooltip = 'Creates a new webhook registration in Vipps Mobilepay and Bc. One Webhook pr MSN allowed.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    VippsMpWebhookSetup: Codeunit "NPR Vipps Mp Webhook Setup";
                    VippsMpUtil: Codeunit "NPR Vipps Mp Util";
                    EnvironmentInformation: Codeunit "Environment Information";
                    VippsMpSetupState: Codeunit "NPR Vipps Mp SetupState";
                    VippsMpStore: Record "NPR Vipps Mp Store";
                    VippsMpWebhook: Record "NPR Vipps Mp Webhook";
                    VippsMpUserPass: Record "NPR Vipps Mp UserPass";
                begin
                    if (not VippsMpStore.Get(VippsMpSetupState.GetCurrentMsn())) then
                        Error('Cant create a webhook without a Merchant Serial Number');
                    if (EnvironmentInformation.IsOnPrem()) then begin
                        VippsMpUserPass.Init();
                        VippsMpUserPass.Insert();
                        Commit();
                        if (Page.RunModal(PAGE::"NPR Vipps Mp UserPass", VippsMpUserPass) = Action::LookupCancel) then
                            exit;
                    end;
                    VippsMpWebhook.Init();
#pragma warning disable AA0139
                    VippsMpWebhook."Webhook Reference" := VippsMpUtil.RemoveCurlyBraces(CreateGuid());
#pragma warning restore AA0139
                    VippsMpWebhook."Merchant Serial Number" := VippsMpStore."Merchant Serial Number";
                    if (EnvironmentInformation.IsOnPrem()) then begin
                        VippsMpWebhook."OnPrem AF Credential Id" := VippsMpUserPass.FriendlyNameId;
#pragma warning disable AA0139
                        VippsMpWebhook."OnPrem AF Credential Key" := VippsMpUtil.RemoveCurlyBraces(CreateGuid());
#pragma warning restore AA0139
                    end;
                    VippsMpWebhook.Insert();
                    VippsMpWebhookSetup.CreateWebhook(VippsMpStore, VippsMpWebhook);
                    if (EnvironmentInformation.IsOnPrem()) then
                        Message(CreateOnPremJsonMsg(VippsMpWebhook, VippsMpUserPass));
                end;
            }

            action("Delete")
            {
                ApplicationArea = NPRRetail;
                Image = Delete;
                Caption = 'Delete Webhook';
                Description = 'Deletes the current webhook both in BC and in Vipps Mobilepay.';
                Tooltip = 'Deletes the current webhook both in BC and in Vipps Mobilepay.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    VippsMpWebhookSetup: Codeunit "NPR Vipps Mp Webhook Setup";
                    VippsMpStore: Record "NPR Vipps Mp Store";
                begin
                    VippsMpStore.Get(Rec."Merchant Serial Number");
                    VippsMpWebhookSetup.DeleteWebhook(VippsMpStore, Rec);
                end;
            }

            action(ListAll)
            {
                ApplicationArea = NPRRetail;
                Image = Text;
                Caption = 'List All';
                Description = 'Lists all webhooks registered for the current MSN in raw format.';
                Tooltip = 'Lists all webhooks registered for the current MSN in raw format.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    VippsMpWebhookSetup: Codeunit "NPR Vipps Mp Webhook Setup";
                    VippsMpSetupState: Codeunit "NPR Vipps Mp SetupState";
                    VippsMpStore: Record "NPR Vipps Mp Store";
                begin
                    VippsMpStore.Get(VippsMpSetupState.GetCurrentMsn());
                    VippsMpWebhookSetup.ListAllWebhooks(VippsMpStore);
                end;
            }

            action(Sync)
            {
                ApplicationArea = NPRRetail;
                Image = Refresh;
                Caption = 'Synchronize Webhooks';
                Description = 'Synchronize webhooks, any webhooks not registered here will be deleted, because the secret is not retrievable, then create a new webhook.';
                Tooltip = 'Synchronize webhooks, any webhooks not registered here will be deleted, because the secret is not retrievable, then create a new webhook.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    VippsMpWebhookSetup: Codeunit "NPR Vipps Mp Webhook Setup";
                    VippsMpStore: Record "NPR Vipps Mp Store";
                    VippsMpSetupState: Codeunit "NPR Vipps Mp SetupState";
                    Deleted: Integer;
                begin
                    VippsMpStore.Get(VippsMpSetupState.GetCurrentMsn());
                    VippsMpWebhookSetup.SynchronizeWebhooks(VippsMpStore, Deleted);
                    if (Deleted > 0) then
                        Message('There were webhooks out of sync. ' + Format(Deleted) + ' have been deleted.')
                    else
                        Message('All webhooks are in sync.')
                end;
            }

            action("AF Configuration")
            {
                Description = 'Generate Json for OnPrem Setup, used in external configuration.';
                ToolTip = 'Generate Json for OnPrem Setup, used in external configuration.';
                ApplicationArea = NPRRetail;
                Image = Action;
                trigger OnAction()
                var
                    tempVippsMpUserPass: Record "NPR Vipps Mp UserPass" temporary;
                begin
                    tempVippsMpUserPass.Init();
                    tempVippsMpUserPass.FriendlyNameId := Rec."OnPrem AF Credential Id";
                    tempVippsMpUserPass.Insert();
                    Commit();
                    if (Page.RunModal(PAGE::"NPR Vipps Mp UserPass", tempVippsMpUserPass) = Action::Cancel) then
                        exit;
                    Message(CreateOnPremJsonMsg(Rec, tempVippsMpUserPass));
                end;
            }
            action("Inspect Webhook Messages")
            {
                Description = 'Opens the Webhook responses page';
                ToolTip = 'Opens the Webhook responses page';
                ApplicationArea = NPRRetail;
                Image = List;
                trigger OnAction()
                begin
                    Page.Run(Page::"NPR Vipps Mp Webhook Msg.");
                end;
            }
        }
    }

    var
        IsOnPrem: Boolean;


    local procedure CreateOnPremJsonMsg(WhRec: Record "NPR Vipps Mp Webhook"; UserPass: Record "NPR Vipps Mp UserPass"): Text
    var
        Json: JsonObject;
        JsonTxt: Text;
        Txt: Label 'The config for "%1" is %2';
    begin
        Json.Add('url', GetUrl(ClientType::SOAP, CompanyName(), ObjectType::Codeunit, Codeunit::"NPR Vipps Mp WebService"));
        Json.Add('username', UserPass.Username);
        Json.Add('password', UserPass.Password);
        Json.Add('credential_key', WhRec."OnPrem AF Credential Key");
        Json.WriteTo(JsonTxt);
        exit(StrSubstNo(Txt, WhRec."OnPrem AF Credential Id", JsonTxt));
    end;

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        IsOnPrem := EnvironmentInformation.IsOnPrem();
    end;
}