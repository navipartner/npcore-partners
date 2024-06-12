page 6184551 "NPR Adyen Webhook Setup List"
{
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Caption = 'Adyen Webhook Setup List';
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
                field("Merchant Accounts Filter Type"; Rec."Merchant Accounts Filter Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Marchant Accounts Filter Type.';
                }
                field("Merchant Accounts Filter"; Rec."Merchant Accounts Filter")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Filter the Merchant Accounts list you want to setup a Webhook for.';
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
                Caption = 'Import Webhooks from Adyen';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Import;
                ToolTip = 'Running this action will import Webhook Setups from Adyen.';

                trigger OnAction()
                var
                    AdyenManagement: Codeunit "NPR Adyen Management";
                    WebhookImportSuccess: Label 'Successfully imported %1 Webhook Setups.';
                    WebhookImportFail: Label 'No Webhook Setups were imported.';
                begin
                    if AdyenManagement.ImportWebhooks(0) then
                        Message(StrSubstNo(WebhookImportSuccess, Format(AdyenManagement.GetImportedWebhooksAmount())))
                    else
                        Error(WebhookImportFail);
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        ConfirmDelete: Label 'Would you like to delete this webhook from Adyen as well?';
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        if Rec.ID <> '' then
            if Confirm(ConfirmDelete) then begin
                AdyenManagement.DeleteWebhook(Rec);
            end;
    end;
}
