page 6151471 "NPR PG Quickpay Setup Card"
{
    Extensible = False;
    Caption = 'Quickpay Setup Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR PG Quickpay Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    Editable = false;
                }
                field("Api Password Key"; PasswordTxt)
                {
                    Caption = 'API Password';
                    ToolTip = 'Specifies the value of the Api Password Key field';
                    ApplicationArea = NPRRetail;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if (PasswordTxt = '') then
                            Rec.DeleteApiPassword()
                        else
                            Rec.SetApiPassword(PasswordTxt);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Test Connectivity")
            {
                Description = 'Test Connectivity';
                ToolTip = 'Tests the connectivity with the QuickPay API based on the current details provided';
                ApplicationArea = NPRRetail;

                Image = Server;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    Integration: Codeunit "NPR Magento Pmt. Quickpay Mgt.";
                    Success: Boolean;
                    ResponseMsg: Text;
                    ConnectionFailedMsg: Label 'The connection with the QuickPay API failed. Maybe you don''t have the "Ping" API permission?\\Last Error Message:\%1', Comment = '%1 = last error message';
                    MessageFromQuickPayMsg: Label 'Message from QuickPay:\%1', Comment = '%1 = message from quickapy api';
                    ConnectionOkMsg: Label 'The connection with the QuickPay API succeeded!';
                begin
                    Success := Integration.TestConnection(Rec.Code, ResponseMsg);

                    if (not Success) then begin
                        Message(ConnectionFailedMsg, GetLastErrorText());
                        exit;
                    end;

                    if (ResponseMsg <> '') then
                        Message(ConnectionOkMsg + '\' + StrSubstNo(MessageFromQuickPayMsg, ResponseMsg))
                    else
                        Message(ConnectionOkMsg);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if (Rec.HasApiPassword()) then
            PasswordTxt := '***';
    end;

    var
        [NonDebuggable]
        PasswordTxt: Text;
}