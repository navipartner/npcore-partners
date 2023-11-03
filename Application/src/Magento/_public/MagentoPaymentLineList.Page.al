page 6151454 "NPR Magento Payment Line List"
{
    Extensible = true;
    AutoSplitKey = true;
    Caption = 'Payment Line List';
    PageType = List;
    SourceTable = "NPR Magento Payment Line";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Table No."; Rec."Document Table No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Document Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Type"; Rec."Payment Type")
                {

                    ToolTip = 'Specifies the value of the Payment Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Account Type"; Rec."Account Type")
                {

                    ToolTip = 'Specifies the value of the Account Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Account No."; Rec."Account No.")
                {

                    ToolTip = 'Specifies the value of the Account No. field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Adjust Amount"; Rec."Allow Adjust Amount")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Allow Adjust Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field(Posted; Rec.Posted)
                {

                    ToolTip = 'Specifies the value of the Posted field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Gateway Code"; Rec."Payment Gateway Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Payment Gateway Code field';
                    ApplicationArea = NPRRetail;
                }
                field("External Reference No."; Rec."External Reference No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the External Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Date Captured"; Rec."Date Captured")
                {

                    ToolTip = 'Specifies the value of the Date Captured field';
                    ApplicationArea = NPRRetail;
                }
                field("Charge ID"; Rec."Charge ID")
                {

                    ToolTip = 'Specifies the value of the Charge ID';
                    ApplicationArea = NPRRetail;
                }
                field("Transaction ID"; Rec."Transaction ID")
                {

                    ToolTip = 'Specifies the value of the Transaction ID';
                    ApplicationArea = NPRRetail;
                }
                field("Date Refunded"; Rec."Date Refunded")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Date Refunded field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control50000; Notes)
            {
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Capture Payment")
            {
                Caption = 'Capture Payment';
                Image = Payment;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = CaptureEnabled;

                ToolTip = 'Executes the Capture Payment action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PaymentLine: Record "NPR Magento Payment Line";
                    MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
                begin
                    if Rec."Date Captured" <> 0D then begin
                        if not Confirm(CapturePaymentAgainQst, false) then
                            exit;
                        Rec."Date Captured" := 0D;
                        CurrPage.Update(true);
                    end;

                    PaymentLine := Rec;
                    MagentoPmtMgt.CapturePaymentLine(PaymentLine);
                    CurrPage.Update(false);
                end;
            }
            action("Refund Payment")
            {
                Caption = 'Refund Payment';
                Image = Payment;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = RefundEnabled;

                ToolTip = 'Executes the Refund Payment action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PaymentLine: Record "NPR Magento Payment Line";
                    MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
                begin
                    if Rec."Date Refunded" <> 0D then begin
                        if not Confirm(RefundPaymentAgainQst, false) then
                            exit;
                        Rec."Date Refunded" := 0D;
                        CurrPage.Update(true);
                    end;

                    PaymentLine := Rec;
                    MagentoPmtMgt.RefundPaymentLine(PaymentLine);
                    CurrPage.Update(false);
                end;
            }
            action("Post Payment")
            {
                Caption = 'Post Payment';
                Image = Post;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = (Rec."Document Table No." = 112) AND (Rec."Account No." <> '') AND (NOT Rec.Posted);

                ToolTip = 'Executes the Post Payment action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
                    MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
                begin
                    MagentoPmtMgt.PostPaymentLine(Rec, GenJnlPostLine);
                    Message(PaymentPostedMsg);
                end;
            }
        }
        area(navigation)
        {
            action("Navi&gate")
            {
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = (Rec."Document Table No." = 112) OR (Rec."Document Table No." = 114);
                ToolTip = 'Executes the Find entries action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NavigateForm: Page Navigate;
                begin
                    NavigateForm.SetDoc(Rec."Posting Date", Rec."Document No.");
                    NavigateForm.Run();
                end;
            }
            action("Show Interaction Log")
            {
                Caption = 'Show Interaction Log';
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Shows the interaction log entries associated with the currently selected line';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PGInteractionLogEntry: Record "NPR PG Interaction Log Entry";
                begin
                    PGInteractionLogEntry.SetFilter("Payment Line System Id", Rec.SystemId);
                    Page.Run(0, PGInteractionLogEntry);
                end;
            }
            action("Document Card")
            {
                Caption = 'Document Card';
                Image = Document;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Document Card action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
                begin
                    MagentoPmtMgt.ShowDocumentCard(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetGatewayEnabled();
    end;

    var
        CapturePaymentAgainQst: Label 'Payment has already been Captured\Capture Again?';
        CaptureEnabled: Boolean;
        RefundEnabled: Boolean;
        RefundPaymentAgainQst: Label 'Payment has already been Refunded\Refund Again?';
        PaymentPostedMsg: Label 'Payment Posted';

    local procedure SetGatewayEnabled()
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        CaptureEnabled := false;
        RefundEnabled := false;

        if Rec."Payment Gateway Code" = '' then
            exit;

        if not PaymentGateway.Get(Rec."Payment Gateway Code") then
            exit;

        CaptureEnabled := PaymentGateway."Enable Capture";
        RefundEnabled := PaymentGateway."Enable Refund";
    end;
}
