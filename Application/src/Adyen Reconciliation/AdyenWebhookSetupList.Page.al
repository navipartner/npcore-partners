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
                    ToolTip = 'Specifies the Webhook Events Filter';
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
                    AdyenManagement: Codeunit "NPR Adyen Management";
                    WebhookImportSuccess: Label 'Successfully imported %1 Webhook Setups.';
                    WebhookImportFail: Label 'No Webhook Setups were imported.';
                    MerchantAccounts: Record "NPR Adyen Merchant Account";
                    ImportedWebhooks: Integer;
                begin
                    AdyenManagement.UpdateMerchantList(0);
                    if MerchantAccounts.FindSet() then begin
                        Clear(ImportedWebhooks);
                        repeat
                            AdyenManagement.ImportWebhooks(0, MerchantAccounts.Name);
                        until MerchantAccounts.Next() = 0;

                        ImportedWebhooks := AdyenManagement.GetImportedWebhooksAmount();
                        if ImportedWebhooks > 0 then
                            Message(StrSubstNo(WebhookImportSuccess, Format(ImportedWebhooks)))
                        else
                            Message(WebhookImportFail);
                    end;
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
}
