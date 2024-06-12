page 6184550 "NPR Adyen Webhook Setup Card"
{
    Extensible = false;
    Caption = 'Adyen Webhook Setup Card';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "NPR Adyen Webhook Setup";
    UsageCategory = None;

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
                field("Include Events Filter"; Rec."Include Events Filter")
                {
                    Caption = 'Include Events Filter';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Event Codes filter that will trigger a Webhook.';
                    Editable = false;
                    TableRelation = "NPR Adyen Webhook Event Code"."Event Code";
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        EventCodes: Page "NPR Adyen Webhook Event Codes";
                        EventCode: Record "NPR Adyen Webhook Event Code";
                        SelectionFilterMgt: Codeunit SelectionFilterManagement;
                        RecRef: RecordRef;
                    begin
                        if (Rec.Type = Rec.Type::standard) then begin
                            Clear(EventCodes);
                            EventCodes.LookupMode := true;
                            if EventCodes.RunModal() = Action::LookupOK then begin
                                EventCodes.SetSelectionFilter(EventCode);
                                RecRef.GetTable(EventCode);
                                Rec."Include Events Filter" := CopyStr(SelectionFilterMgt.GetSelectionFilter(RecRef, EventCode.FieldNo("Event Code")), 1, MaxStrLen(Rec."Include Events Filter"));
                                Rec.Modify();
                                CurrPage.Update();
                            end;
                        end;
                    end;
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
                        RecRef: RecordRef;
                        SelectionFilterMgt: Codeunit SelectionFilterManagement;
                    begin
                        MerchantAccounts.LookupMode := true;
                        if MerchantAccounts.RunModal() = Action::LookupOK then begin
                            MerchantAccounts.SetSelectionFilter(MerchantAccount);
                            RecRef.GetTable(MerchantAccount);
                            Rec."Merchant Accounts Filter" := CopyStr(SelectionFilterMgt.GetSelectionFilter(RecRef, MerchantAccount.FieldNo(Name)), 1, MaxStrLen(Rec."Merchant Accounts Filter"));
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
                    WebhookSetUpSuccess: Label 'Successfully configured Webhook %1.';
                    WebhookSetUpError: Label 'Could not configure current Webhook. Please contact your Administrator.';
                begin
                    if Rec.ID = '' then begin
                        if AdyenManagement.CreateWebhook(Rec) then begin
                            CurrPage.Update(false);
                            Message(StrSubstNo(WebhookSetUpSuccess, Format(Rec.ID)));
                        end else
                            Error(WebhookSetUpError);
                    end;
                end;
            }
            action("Suggest Web Service URL")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Suggest Web Service URL';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Suggest;
                ToolTip = 'Running this action will suggest a Web Service URL to an Azure Function.';

                trigger OnAction()
                var
                    AdyenManagement: Codeunit "NPR Adyen Management";
                begin
                    AdyenManagement.SuggestAFWebServiceURL(Rec);
                    CurrPage.Update();
                end;
            }
            action(Refresh)
            {
                Caption = 'Refresh';
                ApplicationArea = NPRRetail;
                Image = Refresh;
                ToolTip = 'Running this action will Refresh the page.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    Window: Dialog;
                    RefreshingLbl: Label 'Refreshing...';
                    UpdatedLbl: Label 'Configurations were Updated.';
                    UpToDateLbl: Label 'Webhook Setup is already Up to Date.';
                    AdyenManagement: Codeunit "NPR Adyen Management";
                begin
                    Window.Open(RefreshingLbl);
                    if AdyenManagement.RefreshWebhook(Rec) then begin
                        CurrPage.Update();
                        Message(UpdatedLbl);
                    end else
                        Message(UpToDateLbl);
                    Window.Close();
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
