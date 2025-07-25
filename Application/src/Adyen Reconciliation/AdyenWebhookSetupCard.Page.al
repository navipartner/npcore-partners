page 6184550 "NPR Adyen Webhook Setup Card"
{
    Extensible = false;
    Caption = 'NP Pay Webhook Setup Card';
    PageType = Document;
    DataCaptionExpression = Rec.ID;
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
                    Caption = 'Include Event Filter';
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
                        EventsAllowedForStandardLbl: Label 'The event filter can only be set for the "standard" webhook type.';
                        NotPossibleToSetFilterLbl: Label 'The event filter is only editable when the webhook is not yet set up.';
                    begin
                        if (Rec.Type <> Rec.Type::standard) then
                            Error(EventsAllowedForStandardLbl);

                        if Rec.ID <> '' then
                            Error(NotPossibleToSetFilterLbl);

                        Clear(EventCodes);
                        EventCodes.LookupMode := true;
                        if EventCodes.RunModal() = Action::LookupOK then begin
                            EventCodes.SetSelectionFilter(EventCode);
                            RecRef.GetTable(EventCode);
                            Rec."Include Events Filter" := CopyStr(SelectionFilterMgt.GetSelectionFilter(RecRef, EventCode.FieldNo("Event Code")), 1, MaxStrLen(Rec."Include Events Filter"));
                            Rec.Modify();
                            CurrPage.Update(false);
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
            action("Set up a webhook")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Set up a webhook';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Setup;
                ToolTip = 'Running this action will create a Webhook in NP Pay and retrieve its ID.';

                trigger OnAction()
                var
                    WebhookSetUpSuccess: Label 'Successfully configured Webhook %1.';
                    WebhookSetUpError: Label 'Could not configure current Webhook. Please contact your Administrator.';
                begin
                    if Rec.ID = '' then begin
                        if _AdyenManagement.CreateWebhook(Rec) then begin
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
                begin
                    _AdyenManagement.SuggestAFWebServiceURL(Rec);
                    CurrPage.Update(false);
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
                begin
                    Window.Open(RefreshingLbl);
                    if _AdyenManagement.RefreshWebhook(Rec) then begin
                        CurrPage.Update(false);
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

    trigger OnOpenPage()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        WebhookCanNotBeSyncLbl: Label 'Failed to synchronize Webhook setup with NP Pay.\Please ensure your API Management Key is configured and valid.';
    begin
        if Rec.ID <> '' then begin
            if (not AdyenSetup.Get()) or (not _AdyenManagement.TestApiKey(AdyenSetup."Environment Type")) then
                Message(WebhookCanNotBeSyncLbl);
            _AdyenManagement.RefreshWebhook(Rec);
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec.ID <> '' then
            _WebhookCreated := true;
    end;

    var
        _AdyenManagement: Codeunit "NPR Adyen Management";
        _WebhookCreated: Boolean;
}
