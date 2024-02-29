page 6151488 "NPR Vipps Mp Webhook Msg."
{
    PageType = List;
    Caption = 'Webhook Messages';
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = True;
    Extensible = False;
    SourceTable = "NPR Vipps Mp Webhook Msg";
    SourceTableView = SORTING(ReceivedAt)
                      ORDER(Descending);

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ReceivedAt; Rec.ReceivedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the message was received from the webhook.';
                }
                field("Webhook Reference"; Rec."Webhook Reference")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies which webhook was used.';
                }
                field("Event Type"; Rec."Event Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies which event type was sent via the webhook.';
                }
                field("Operation Reference"; Rec."Operation Reference")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the identifier of the operation in the webhook message.';
                }
                field("Message"; Rec.Message.HasValue())
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Has Message';
                    ToolTip = 'Specifies if there is a message.';
                }
                field(Verified; Rec.Verified)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the webhook message was verified.';
                }
                field("Error"; Rec.Error)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if a failure occurred when receiving and parsing the webhook. See last part of message to see error.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ReadWebhookMessage)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Read Webhook Message';
                ToolTip = 'Reads the raw data fo the Message.';
                Image = Text;

                trigger OnAction();
                var
                    Ins: InStream;
                    Txt: Text;
                begin
                    if (Rec.Message.HasValue()) then begin
                        Rec.CalcFields(Message);
                        Rec.Message.CreateInStream(Ins, TextEncoding::UTF8);
                        Ins.ReadText(Txt);
                        Message(Txt);
                    end
                end;
            }
            action("Delete Record")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Delete Record';
                ToolTip = 'Deletes the Record.';
                Image = Delete;

                trigger OnAction();
                begin
                    Rec.Delete();
                end;
            }
            action("Delete All")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Delete All';
                ToolTip = 'Delete All records.';
                Image = Delete;

                trigger OnAction();
                begin
                    Rec.DeleteAll();
                end;
            }
        }
    }
}