#if not BC17
page 6184707 "NPR Spfy Webhook Notifications"
{
    Extensible = false;
    ApplicationArea = NPRShopify;
    Caption = 'Shopify Webhook Notifications';
    PageType = List;
    SourceTable = "NPR Spfy Webhook Notification";
    SourceTableView = order(descending);
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of the webhook notification entry, as assigned from the specified number series when the entry was created.';
                    ApplicationArea = NPRShopify;
                }
                field("Shop Domain"; Rec."Shop Domain")
                {
                    ToolTip = 'Specifies the Shopify store the webhook notification was created for.';
                    ApplicationArea = NPRShopify;
                }
                field("Event ID"; Rec."Event ID")
                {
                    ToolTip = 'Specifies Shopify event ID.';
                    ApplicationArea = NPRShopify;
                }
                field("Webhook ID"; Rec."Webhook ID")
                {
                    ToolTip = 'Specifies Shopify webhook ID.';
                    ApplicationArea = NPRShopify;
                }
                field(Topic; Rec."Topic (Received)")
                {
                    ToolTip = 'Specifies Shopify notification topic.';
                    ApplicationArea = NPRShopify;
                }
                field("Triggered for Source ID"; Rec."Triggered for Source ID")
                {
                    ToolTip = 'Specifies the Shopify object ID for which the webhook notification was triggered.';
                    ApplicationArea = NPRShopify;
                }
                field("Triggered At"; Rec."Triggered At")
                {
                    ToolTip = 'Specifies the date and time when the notification was created at Shopify.';
                    ApplicationArea = NPRShopify;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Received from Shopify at';
                    ToolTip = 'Specifies the date and time when the notification was received in Business Central.';
                    ApplicationArea = NPRShopify;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the processing status of the webhook notification entry in BC.';
                    ApplicationArea = NPRShopify;
                }
                field("Number of Process Attempts"; Rec."Number of Process Attempts")
                {
                    ToolTip = 'Specifies the number of times the system has attempted to process this Shopify webhook notification. Please note that the system will attempt to process an erroneous webhook notification 3 times, after which the record will be cancelled if it stil fails.';
                    ApplicationArea = NPRShopify;
                }
                field("Processed at"; Rec."Processed at")
                {
                    ToolTip = 'Specifies the date and time when the notification entry was successfully processed in BC.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
        area(factboxes)
        {
            part(NotificationPayload; "NPR Spfy WH Notif.Line FactBox")
            {
                ApplicationArea = NPRShopify;
                Editable = false;
                SubPageLink = "Entry No." = field("Entry No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowErrorMessage)
            {
                Caption = 'Show Error';
                ToolTip = 'Shows the error message raised by the notification processing (if the process has failed).';
                Image = PrevErrorMessage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = NPRShopify;

                trigger OnAction()
                begin
                    if not (Rec.Status in [Rec.Status::Error, Rec.Status::Cancelled]) then
                        Rec.FieldError(Status);
                    Message(Rec.GetErrorMessage());
                end;
            }
            action(ReprocessSelectedFailedUpdates)
            {
                Caption = 'Reprocess Selected';
                ToolTip = 'Repeats the processing of the selected records on the page.';
                Image = NegativeLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = NPRShopify;

                trigger OnAction()
                var
                    SpfyWebhookNotification: Record "NPR Spfy Webhook Notification";
                    SpfyWebhookNotifHandler: Codeunit "NPR Spfy Webhook Notif.Handler";
                begin
                    CurrPage.SetSelectionFilter(SpfyWebhookNotification);
                    SpfyWebhookNotifHandler.ProcessWebhookNotifications(SpfyWebhookNotification, true);
                    CurrPage.Update(false);
                end;
            }
            action(ShowRelated)
            {
                Caption = 'Show Related';
                ToolTip = 'Navigates to the related record in Business Central.';
                Image = ViewSourceDocumentLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = NPRShopify;

                trigger OnAction()
                var
                    SpfyWebhookNotifIHndlr: Interface "NPR Spfy Webhook Notif. IHndlr";
                    SpfyWebhookNotifParser: Codeunit "NPR Spfy Webhook Notif. Parser";
                begin
                    if Rec.Topic = Rec.Topic::UNDEFINED then
                        SpfyWebhookNotifParser.IdentifyTopic(Rec);
                    SpfyWebhookNotifIHndlr := Rec.Topic;
                    SpfyWebhookNotifIHndlr.NavigateToRelatedBCEntity(Rec);
                end;
            }
            action(ShowAFRawPayload)
            {
                Caption = 'Show AF Raw Payload';
                ToolTip = 'Shows raw payload as recieved from the Azure function.';
                Image = ViewSourceDocumentLine;
                ApplicationArea = NPRShopify;

                trigger OnAction()
                var
                    AFRawPayloadString: Text;
                    NoInputTxt: Label 'No payload was registered for the webhook notification.';
                begin
                    AFRawPayloadString := Rec.GetAFRawPayload();
                    if AFRawPayloadString <> '' then
                        Message(AFRawPayloadString)
                    else
                        Message(NoInputTxt);
                end;
            }
            action(ReReadAFPayload)
            {
                Caption = 'Re-read Notification Details';
                ToolTip = 'Re-read the webhook notification details from the original data received from the Azure function.';
                Image = ReverseLines;
                ApplicationArea = NPRShopify;

                trigger OnAction()
                var
                    SpfyWebhookNotifParser: Codeunit "NPR Spfy Webhook Notif. Parser";
                begin
                    if Rec.Status = Rec.Status::Processed then
                        Rec.FieldError(Status);

                    Rec.Status := Rec.Status::New;
                    SpfyWebhookNotifParser.SetWebhook(Rec.GetAFRawPayload());
                    if not SpfyWebhookNotifParser.TryReadNotificationDetails(Rec) then begin
                        Rec.Status := Rec.Status::Error;
                        Rec.SetErrorMessage(GetLastErrorText());
                    end;
                    CurrPage.Update(true);
                end;
            }
        }
    }
}
#endif