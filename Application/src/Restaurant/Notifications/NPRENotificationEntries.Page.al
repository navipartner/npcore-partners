page 6184524 "NPR NPRE Notification Entries"
{
    Extensible = False;
    Caption = 'Restaurant Notifications';
    PageType = List;
    SourceTable = "NPR NPRE Notification Entry";
    SourceTableView = order(descending);
    UsageCategory = Tasks;
    ApplicationArea = NPRRetail;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of the notification entry, as assigned from the specified number series when the entry was created.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Kitchen Order ID"; Rec."Kitchen Order ID")
                {
                    ToolTip = 'Specifies the kitchen order Id for which this notification was created.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Kitchen Request No."; Rec."Kitchen Request No.")
                {
                    ToolTip = 'Specifies the kitchen request number for which this notification was created.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Notification Trigger"; Rec."Notification Trigger")
                {
                    ToolTip = 'Specifies the notification trigger that created this notification.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Created at Date-Time';
                    ToolTip = 'Specifies the date and time when the notification was created.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Notify at Date-Time"; Rec."Notify at Date-Time")
                {
                    ToolTip = 'Specifies the earliest possible date and time at which the notification is to be sent.';
                    ApplicationArea = NPRRetail;
                }
                field("Expires at Date-Time"; Rec."Expires at Date-Time")
                {
                    ToolTip = 'Specifies the notification expiry date and time. If the notification hasn’t been sent by this time, the system will not attempt to send it again.';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Method"; Rec."Notification Method")
                {
                    ToolTip = 'Specifies the notification method, whether it is an e-mail or a text message (SMS).';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(Recipient; Rec.Recipient)
                {
                    ToolTip = 'Specifies the type of recipient for the notification.';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Template"; Rec."Notification Template")
                {
                    ToolTip = 'Specifies the template code to be used to generate the notification details.';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Address"; Rec."Notification Address")
                {
                    ToolTip = 'Specifies the address of the notification recipient. This can be an email address or a phone number, depending on the notification method and recipient type. If the field is empty, the system will use the default recipient(s) from the template.';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Send Status"; Rec."Notification Send Status")
                {
                    ToolTip = 'Specifies the notification sending status.';
                    ApplicationArea = NPRRetail;
                }
                field("Sending Result Message"; Rec."Sending Result Message")
                {
                    ToolTip = 'Specifies the message that describes the problem if the system was unable to send the notification or retrieve the notification send result from the notification processing handler.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Notification Sent at"; Rec."Sent at")
                {
                    ToolTip = 'Specifies the date and time the notification was sent.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Notification Sent By"; Rec."Sent By")
                {
                    ToolTip = 'Specifies the user ID that sent the notification.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("From Message Log Entry No."; Rec."From Message Log Entry No.")
                {
                    ToolTip = 'Specifies the first SMS sending log entry number created for this notification.';
                    ApplicationArea = NPRRetail;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownRelatedLogEntries();
                    end;
                }
                field("To Message Log Entry No."; Rec."To Message Log Entry No.")
                {
                    ToolTip = 'Specifies the last SMS sending log entry number created for this notification.';
                    ApplicationArea = NPRRetail;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownRelatedLogEntries();
                    end;
                }
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
                ToolTip = 'Shows the full message that describes the problem if the system was unable to send the notification or retrieve the notification send result from the notification processing handler.';
                ApplicationArea = NPRHeyLoyalty;
                Image = PrevErrorMessage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    if not Rec.SendingFailed() then
                        Rec.FieldError("Notification Send Status");
                    Message(Rec.GetErrorMessage());
                end;
            }
        }
    }
}
