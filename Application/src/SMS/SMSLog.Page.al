page 6014432 "NPR SMS Log"
{

    ApplicationArea = All;
    Caption = 'SMS Log';
    PageType = List;
    SourceTable = "NPR SMS Log";
    UsageCategory = Administration;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Sender No."; Rec."Sender No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sender No. field';
                }
                field("Reciepient No."; Rec."Reciepient No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reciepient No. field';
                }
                field("Date Time Sent"; Rec."Date Time Sent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Time Sent field';
                }
                field("Send on Date Time"; Rec."Send on Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send on Date Time field';
                }
                field("Send Attempts"; Rec."Send Attempts")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Attempts field';
                }
                field("Last Send Attempt"; Rec."Last Send Attempt")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Send Attempt field';
                }
                field("User Notified"; Rec."User Notified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User NotifiedSend Attempts field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Set Pending action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Set Discard action';
                Image = Error;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Show Message action';
                Image = Error;
                trigger OnAction()
                var
                    MessageLog: Record "NPR SMS Log";
                    Msg: Text;
                    InStr: InStream;
                begin
                    CurrPage.SetSelectionFilter(MessageLog);
                    if MessageLog.FindFirst() then begin
                        MessageLog.CalcFields(Message);
                        if MessageLog.Message.HasValue then begin
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
                ApplicationArea = All;
                ToolTip = 'Executes the Show Error Message action';
                Image = Error;
                trigger OnAction()
                var
                    MessageLog: Record "NPR SMS Log";
                    ErrorMsg: Text;
                    InStr: InStream;
                begin
                    CurrPage.SetSelectionFilter(MessageLog);
                    if MessageLog.FindFirst() then begin
                        MessageLog.CalcFields("Error Message");
                        if MessageLog."Error Message".HasValue then begin
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
