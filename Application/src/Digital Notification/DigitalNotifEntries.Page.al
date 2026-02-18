#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6150918 "NPR Digital Notif. Entries"
{
    Caption = 'Digital Notification Entries';
    PageType = List;
    SourceTable = "NPR Digital Notification Entry";
    SourceTableView = sorting("Entry No.")
                      order(descending);
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the entry number.';
                }
                field("External Order No."; Rec."External Order No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the external order number.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the document type (Invoice, Credit Memo, or Ecom Sales Document).';
                }
                field("Posted Document No."; Rec."Posted Document No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the posted document number.';
                }
                field("Recipient E-mail"; Rec."Recipient E-mail")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the recipient email address.';
                }
                field("Recipient Name"; Rec."Recipient Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the recipient name.';
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the language code for the notification.';
                }
                field("Email Template Id"; Rec."Email Template Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the email template used.';
                }
                field(Sent; Rec.Sent)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the notification has been sent.';
                }
                field("Created Date-Time"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the notification entry was created.';
                }
                field("Sent Date-Time"; Rec."Sent Date-Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the notification was sent.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies any error message if the notification failed to send.';
                }
                field("Attempt Count"; Rec."Attempt Count")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the number of attempts made to send this notification.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SendNotifications)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Send Notifications';
                ToolTip = 'Manually send all pending notifications. Hidden when automatic job queue is active.';
                Image = SendMail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Visible = not IsJobQueueActive;

                trigger OnAction()
                var
                    NotifEntry: Record "NPR Digital Notification Entry";
                    DigitalNotificationSend: Codeunit "NPR Digital Notification Send";
                    SendingCompletedMsg: Label 'Notification sending completed.';
                    NoEntriesMsg: Label 'There are no pending notifications to send. All notifications have either been sent or have exceeded the maximum number of attempts.';
                begin
                    DigitalNotificationSend.FilterNotificationsToSend(NotifEntry);
                    if NotifEntry.IsEmpty then begin
                        Message(NoEntriesMsg);
                        exit;
                    end;

                    DigitalNotificationSend.Run();
                    CurrPage.Update(false);
                    Message(SendingCompletedMsg);
                end;
            }
            action(SendNotification)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Send Notification';
                ToolTip = 'Manually send the selected notification entry. Hidden when automatic job queue is active.';
                Image = SendEmailPDF;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Visible = not IsJobQueueActive;

                trigger OnAction()
                var
                    NotifEntry: Record "NPR Digital Notification Entry";
                    DigitalNotificationSend: Codeunit "NPR Digital Notification Send";
                    SendingSuccessMsg: Label 'Notification sent successfully.';
                    SendingFailedMsg: Label 'Failed to send notification: %1';
                    AlreadySentErr: Label 'This notification has already been sent. To resend, first use the "Reset Attempt Count" action to reset the notification status.';
                begin
                    if Rec.Sent then
                        Error(AlreadySentErr);

                    NotifEntry := Rec;
                    if DigitalNotificationSend.SendNotification(NotifEntry) then begin
                        CurrPage.Update(false);
                        Message(SendingSuccessMsg);
                    end else begin
                        CurrPage.Update(false);
                        Message(SendingFailedMsg, NotifEntry."Error Message");
                    end;
                end;
            }
            action(ResetAttemptCount)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Reset Attempt Count';
                ToolTip = 'Reset the attempt count to zero so the notification can be retried.';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    NotifEntry: Record "NPR Digital Notification Entry";
                    DigitalNotificationSend: Codeunit "NPR Digital Notification Send";
                    ConfirmMgt: Codeunit "Confirm Management";
                    ResetMsg: Label 'Attempt count has been reset. The notification will be retried in the next processing cycle.';
                    AlreadySentConfirmQst: Label 'This notification has already been sent to the customer. Resetting the attempt count will cause the system to send another email to the customer. Do you want to continue?';
                    ResetConfirmQst: Label 'Do you want to reset the attempt count for this notification?';
                begin
                    NotifEntry := Rec;

                    if NotifEntry.Sent then begin
                        if not ConfirmMgt.GetResponseOrDefault(AlreadySentConfirmQst, false) then
                            exit;
                    end else begin
                        if not ConfirmMgt.GetResponseOrDefault(ResetConfirmQst, true) then
                            exit;
                    end;

                    DigitalNotificationSend.ResetAttemptCount(NotifEntry);
                    CurrPage.Update(false);
                    Message(ResetMsg);
                end;
            }
            action(OpenManifestUrl)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Open Manifest URL';
                ToolTip = 'Opens the manifest URL in a browser to view the digital assets.';
                Image = Web;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ManifestUrl: Text[250];
                    NoManifestUrlMsg: Label 'No manifest URL available for this entry.';
                begin
                    ManifestUrl := GetManifestUrl(Rec."Manifest ID");
                    if ManifestUrl <> '' then
                        Hyperlink(ManifestUrl)
                    else
                        Message(NoManifestUrlMsg);
                end;
            }
        }
    }

    var
        IsJobQueueActive: Boolean;

    trigger OnOpenPage()
    var
        DigitalNotificationSend: Codeunit "NPR Digital Notification Send";
    begin
        IsJobQueueActive := DigitalNotificationSend.IsJobQueueActive();
    end;

    local procedure GetManifestUrl(ManifestId: Guid) Url: Text[250]
    var
        NpDesigner: Codeunit "NPR NPDesigner";
    begin
        if IsNullGuid(ManifestId) then
            exit;

        NpDesigner.GetManifestUrl(ManifestId, Url);
    end;
}
#endif
