page 6184551 "NPR Adyen Webhook Setup List"
{
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Caption = 'NP Pay Webhook Setup List';
    PageType = List;
    SourceTable = "NPR Adyen Webhook Setup";
    SourceTableView = sorting("Primary Key") order(descending);
    CardPageID = "NPR Adyen Webhook Setup Card";
    RefreshOnActivate = true;
    Extensible = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Webhook ID.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Webhook Type.';
                }
                field("Include Events Filter"; Rec."Include Events Filter")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Webhook Event Filter';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Webhook Description.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Webhook is Active.';
                }
                field("Merchant Account"; Rec."Merchant Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Merchant Account the current Webhook will work for.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Import Webhooks from Adyen")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Import Webhooks from NP Pay';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Import;
                ToolTip = 'Running this action will import Webhook Setups from NP Pay.';

                trigger OnAction()
                var
                    Sentry: Codeunit "NPR Sentry";
                    AdyenImportScope: Label 'NP Pay Import Webhooks', Locked = true;
                    WebhookImportSuccess: Label 'Successfully imported %1 Webhook Setups.';
                    WebhookImportFail: Label 'No Webhook Setups were imported.';
                    ImportedWebhooks: Integer;
                    MerchantsFound: Boolean;
                    ImportError: Text;
                begin
                    Sentry.InitScopeAndTransaction(AdyenImportScope, 'bc.nppay.webhook.import');

                    if not TryImportWebhooks(MerchantsFound, ImportedWebhooks) then begin
                        ImportError := GetLastErrorText();
                        Sentry.AddLastErrorIfProgrammingBug();
                    end;
                    Sentry.FinalizeScope();

                    if ImportError <> '' then
                        Error(ImportError);

                    if MerchantsFound then
                        if ImportedWebhooks > 0 then
                            Message(StrSubstNo(WebhookImportSuccess, Format(ImportedWebhooks)))
                        else
                            Message(WebhookImportFail);
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        ConfirmDelete: Label 'Would you like to delete this webhook from NP Pay as well?';
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        if Rec.ID <> '' then
            if Confirm(ConfirmDelete) then begin
                AdyenManagement.DeleteWebhook(Rec);
            end;
    end;

    [TryFunction]
    local procedure TryImportWebhooks(var MerchantsFound: Boolean; var ImportedWebhooks: Integer)
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        MerchantAccounts: Record "NPR Adyen Merchant Account";
    begin
        AdyenManagement.UpdateMerchantList(0);

        MerchantsFound := MerchantAccounts.FindSet();
        if not MerchantsFound then
            exit;

        repeat
            AdyenManagement.ImportWebhooks(0, MerchantAccounts.Name);
        until MerchantAccounts.Next() = 0;

        ImportedWebhooks := AdyenManagement.GetImportedWebhooksAmount();
    end;
}
