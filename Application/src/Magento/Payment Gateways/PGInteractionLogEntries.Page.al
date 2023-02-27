page 6151473 "NPR PG Interaction Log Entries"
{
    Extensible = false;
    Caption = 'Payment Gateways Interactions Log Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR PG Interaction Log Entry";
    SourceTableView = sorting("Entry No.") order(descending);
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the unique auto-increment value of the NPR M2 PG Interactions Log table';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Line System Id"; Rec."Payment Line System Id")
                {
                    ToolTip = 'Specifies the value of the Payment Line System Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Interaction Type"; Rec."Interaction Type")
                {
                    ToolTip = 'Specifies the value of the Interaction Type field';
                    ApplicationArea = NPRRetail;
                }
                field("In Progress"; Rec."In Progress")
                {
                    ToolTip = 'Specifies the value of the Interaction Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Ran With Error"; Rec."Ran With Error")
                {
                    ToolTip = 'Specifies the value of the Ran With Error field';
                    ApplicationArea = NPRRetail;
                }
                field("Operation Success"; Rec."Operation Success")
                {
                    ToolTip = 'Specifies the value of the Operation Success field';
                    ApplicationArea = NPRRetail;
                }
                field(HasErrorMessage; Rec."Error Message".HasValue())
                {
                    Caption = 'Has Error Message';
                    ToolTip = 'Specifies if the line has an error message registered';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        ShowErrorMessage();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Show Request Object")
            {
                Caption = 'Show Request Object';
                ToolTip = 'Displays a JSON representation of the request object sent to the payment gateway integration';
                Image = Document;
                ApplicationArea = NPRRetail;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    Buffer: Text;
                    IStr: InStream;
                    RequestObjectTxt: Text;
                begin
                    if (not Rec."Request Object".HasValue()) then begin
                        Message(NoRequestObjectMsg);
                        exit;
                    end;

                    Rec.CalcFields("Request Object");
                    Rec."Request Object".CreateInStream(IStr);
                    while (not IStr.EOS()) do begin
                        IStr.ReadText(Buffer);
                        RequestObjectTxt += Buffer;
                    end;

                    Message('%1', RequestObjectTxt);// We do this weird thing to avoid JSON escape character being treated as a line break.
                end;
            }
            action("Show Response Object")
            {
                Caption = 'Show Response Object';
                ToolTip = 'Displays a JSON representation of the response object returned from the payment gateway integration';
                Image = Document;
                ApplicationArea = NPRRetail;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    Buffer: Text;
                    IStr: InStream;
                    ResponseObjectTxt: Text;
                begin
                    if (not Rec."Response Object".HasValue()) then begin
                        Message(NoResponseObjectMsg);
                        exit;
                    end;

                    Rec.CalcFields("Response Object");
                    Rec."Response Object".CreateInStream(IStr);
                    while (not IStr.EOS()) do begin
                        IStr.ReadText(Buffer);
                        ResponseObjectTxt += Buffer;
                    end;

                    Message('%1', ResponseObjectTxt); // We do this weird thing to avoid JSON escape character being treated as a line break.
                end;
            }
            action("Show Error Message")
            {
                Caption = 'Show Error Message';
                ToolTip = 'Displays the error message recorded for the selected record';
                Image = PrevErrorMessage;
                ApplicationArea = NPRRetail;
                Enabled = HasErrorMessage;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    ShowErrorMessage();
                end;
            }
        }
    }

    var
        NoRequestObjectMsg: Label 'No request object to display.';
        NoResponseObjectMsg: Label 'No response object to display.';
        NoErrorMessageRecordedMsg: Label 'No error message recorded.';
        HasErrorMessage: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        HasErrorMessage := Rec."Error Message".HasValue();
    end;

    local procedure ShowErrorMessage()
    var
        IStr: InStream;
        Buffer: Text;
        ErrorMsg: Text;
    begin
        if (not Rec."Error Message".HasValue()) then begin
            Message(NoErrorMessageRecordedMsg);
            exit;
        end;

        Rec.CalcFields("Error Message");
        Rec."Error Message".CreateInStream(IStr);
        while (not IStr.EOS()) do begin
            IStr.ReadText(Buffer);
            ErrorMsg += Buffer;
        end;

        Message(ErrorMsg);
    end;
}

