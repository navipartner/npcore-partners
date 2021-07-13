page 6014432 "NPR SMS Log"
{


    Caption = 'SMS Log';
    PageType = List;
    SourceTable = "NPR SMS Log";
    UsageCategory = Administration;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Sender No."; Rec."Sender No.")
                {

                    ToolTip = 'Specifies the value of the Sender No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Reciepient No."; Rec."Reciepient No.")
                {

                    ToolTip = 'Specifies the value of the Reciepient No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Date Time Sent"; Rec."Date Time Sent")
                {

                    ToolTip = 'Specifies the value of the Date Time Sent field';
                    ApplicationArea = NPRRetail;
                }
                field("Send on Date Time"; Rec."Send on Date Time")
                {

                    ToolTip = 'Specifies the value of the Send on Date Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Send Attempts"; Rec."Send Attempts")
                {

                    ToolTip = 'Specifies the value of the Send Attempts field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Send Attempt"; Rec."Last Send Attempt")
                {

                    ToolTip = 'Specifies the value of the Last Send Attempt field';
                    ApplicationArea = NPRRetail;
                }
                field("User Notified"; Rec."User Notified")
                {

                    ToolTip = 'Specifies the value of the User NotifiedSend Attempts field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Pending)
            {
                Caption = 'Set Pending';

                ToolTip = 'Executes the Set Pending action';
                Image = CreateLinesFromTimesheet;
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    MessageLog: Record "NPR SMS Log";
                begin
                    CurrPage.SetSelectionFilter(MessageLog);
                    MessageLog.SetRange(Status, MessageLog.Status::Error);
                    MessageLog.ModifyAll(Status, MessageLog.Status::Pending);
                end;
            }
            action(Discard)
            {
                Caption = 'Set Discard';

                ToolTip = 'Executes the Set Discard action';
                Image = Error;
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    MessageLog: Record "NPR SMS Log";
                begin
                    CurrPage.SetSelectionFilter(MessageLog);
                    MessageLog.SetFilter(Status, '%1|%2', MessageLog.Status::Error, MessageLog.Status::Pending);
                    MessageLog.ModifyAll(Status, MessageLog.Status::Discard);
                end;
            }
            action(ShowMessage)
            {
                Caption = 'Show Message';

                ToolTip = 'Executes the Show Message action';
                Image = Error;
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    MessageLog: Record "NPR SMS Log";
                    Msg: Text;
                    InStr: InStream;
                begin
                    CurrPage.SetSelectionFilter(MessageLog);
                    if MessageLog.FindFirst() then begin
                        MessageLog.CalcFields(Message);
                        if MessageLog.Message.HasValue() then begin
                            MessageLog.Message.CreateInStream(InStr);
                            InStr.Read(Msg);
                            Message(Msg);
                        end;
                    end;

                end;
            }
            action(ShowErrorMessage)
            {
                Caption = 'Show Error Message';

                ToolTip = 'Executes the Show Error Message action';
                Image = Error;
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    MessageLog: Record "NPR SMS Log";
                    ErrorMsg: Text;
                    InStr: InStream;
                begin
                    CurrPage.SetSelectionFilter(MessageLog);
                    if MessageLog.FindFirst() then begin
                        MessageLog.CalcFields("Error Message");
                        if MessageLog."Error Message".HasValue() then begin
                            MessageLog."Error Message".CreateInStream(InStr);
                            InStr.Read(ErrorMsg);
                            Message(ErrorMsg);
                        end;
                    end;

                end;
            }
        }
    }
}
