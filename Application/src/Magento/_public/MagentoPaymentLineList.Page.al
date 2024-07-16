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
                field("Requested Amount"; Rec."Requested Amount")
                {
                    ToolTip = 'Specifies the value of the Requested Amount field';
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
                field("Posting Error"; Rec."Posting Error")
                {
                    ToolTip = 'Specifies the value of the Posting Error field';
                    ApplicationArea = NPRRetail;
                }
                field("Skip Posting"; Rec."Skip Posting")
                {
                    ToolTip = 'Specifies the value of the Skip Posting field';
                    ApplicationArea = NPRRetail;
                }
                field("Try Posting Count"; Rec."Try Posting Count")
                {
                    ToolTip = 'Specifies the value of the Try Posting Count field';
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
                    ToolTip = 'Specifies the value of the Date Refunded field';
                    ApplicationArea = NPRRetail;
                }
                field("Date Canceled"; Rec."Date Canceled")
                {
                    Visible = true;
                    ToolTip = 'Specifies the value of the Date Canceled field.';
                    ApplicationArea = NPRRetail;
                }
                field("Date Authorized"; Rec."Date Authorized")
                {
                    Visible = true;
                    ToolTip = 'Specifies the value of the Date Canceled field.';
                    ApplicationArea = NPRRetail;
                }
#if not BC17
                field("Spfy Payment Transaction ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Shopify Transaction ID';
                    Editable = false;
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies Shopify payment transaction ID.';
                }
#endif
                field(Reconciled; Rec.Reconciled)
                {
                    ToolTip = 'Specifies if the payment is Reconciled in an Adyen Reconciliation Document.';
                    ApplicationArea = NPRRetail;
                }
                field("Pay by Link URL"; Rec."Pay by Link URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Pay by Link URL';
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec."Pay by Link URL");
                    end;
                }
                field("Payment ID"; Rec."Payment ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment ID field.';
                    Editable = false;
                }
                field("Manually Canceled Link"; Rec."Manually Canceled Link")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Manually Cancelled Link field.';
                    Editable = false;
                }
                field("Expires At"; Rec."Expires At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Expires At field.';
                    Editable = false;
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
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if Rec."Date Captured" <> 0D then begin
                        if not Confirm(CapturePaymentAgainQst, false) then
                            exit;
                        Rec."Date Captured" := 0D;
                        CurrPage.Update(true);
                    end else
                        if not ConfirmManagement.GetResponseOrDefault(CapturePaymentQst, true) then
                            exit;

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
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if Rec."Date Refunded" <> 0D then begin
                        if not Confirm(RefundPaymentAgainQst, false) then
                            exit;
                        Rec."Date Refunded" := 0D;
                        CurrPage.Update(true);
                    end else
                        if not ConfirmManagement.GetResponseOrDefault(RefundPaymentQst, true) then
                            exit;

                    PaymentLine := Rec;
                    MagentoPmtMgt.RefundPaymentLine(PaymentLine);
                    CurrPage.Update(false);
                end;
            }
            action("Cancel Payment")
            {
                Caption = 'Cancel Payment';
                Image = Cancel;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = RefundEnabled;
                ToolTip = 'Executes the Cancel Payment action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PaymentLine: Record "NPR Magento Payment Line";
                    MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    Rec.TestField("Date Captured", 0D);
                    if Rec."Date Canceled" <> 0D then begin
                        if not Confirm(CancelPaymentAgainQst, false) then
                            exit;
                        Rec."Date Canceled" := 0D;
                        CurrPage.Update(true);
                    end else
                        if not ConfirmManagement.GetResponseOrDefault(CancelPaymentQst, true) then
                            exit;

                    PaymentLine := Rec;
                    MagentoPmtMgt.CancelPaymentLine(PaymentLine);
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
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if not ConfirmManagement.GetResponseOrDefault(PostPaymentQst, true) then
                        exit;

                    MagentoPmtMgt.PostPaymentLine(Rec, GenJnlPostLine);
                    Message(PaymentPostedMsg);
                end;
            }
            action("Reset Posting Error")
            {
                Caption = 'Reset posting Error';
                Image = ResetStatus;
                Visible = (Rec."Posting Error" = true) OR (Rec."Skip Posting");
                ToolTip = 'Resets all fields related to posting errors';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MagentoPmtAdyenMgt: Codeunit "NPR Magento Pmt. Adyen Mgt.";
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if not ConfirmManagement.GetResponseOrDefault(ResetPostingErrQst, true) then
                        exit;
                    MagentoPmtAdyenMgt.ResetErrorPostingStatus(Rec);
                    CurrPage.Update(false);
                end;
            }
            action("Set Skip Posting")
            {
                Caption = 'Set Skip Posting';
                Image = CancelLine;
                ToolTip = 'Sets field Skip Posting to true.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MagentoPmtAdyenMgt: Codeunit "NPR Magento Pmt. Adyen Mgt.";
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if not ConfirmManagement.GetResponseOrDefault(SkipPostingQst, true) then
                        exit;
                    MagentoPmtAdyenMgt.SetSkipPosting(Rec);
                    CurrPage.Update(false);
                end;
            }

            action("Cancel Pay by Link")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Cancel Pay by Link';
                ToolTip = 'Cancel Pay by Link';
                Image = Cancel;

                trigger OnAction()
                var
                    PaybyLink: Interface "NPR Pay by Link";
                    PayByLinkSetup: Record "NPR Pay By Link Setup";
                    MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
                begin
                    if not Confirm(CancelPayByLinkQst, false) then
                        exit;

                    PayByLinkSetup.Get();
                    MagentoPaymentGateway.Get(PayByLinkSetup."Payment Gateaway Code");
                    PaybyLink := MagentoPaymentGateway."Integration Type";
                    PaybyLink.CancelPayByLink(Rec);
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
            action("Show Posting Log")
            {
                Caption = 'Show Posting Log';
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Shows the posting log entries associated with the currently selected line';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PGPostingLogEntry: Record "NPR PG Posting Log Entry";
                begin
                    PGPostingLogEntry.SetFilter("Payment Line System Id", Rec.SystemId);
                    Page.Run(0, PGPostingLogEntry);
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
            group(PayByLink)
            {
                Caption = 'Pay by Link';
                Image = LinkWeb;
                action("NPR E-mail log")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Pay by Link E-mail log';
                    Image = Email;
                    ToolTip = 'Executes the Pay by Link E-mail log action.';
                    trigger OnAction()
                    var
                        EmailManagement: Codeunit "NPR E-mail Management";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        EmailManagement.RunEmailLog(RecRef);
                    end;
                }
                action("NPR Resend PayByLink")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Resend Pay by Link';
                    ToolTip = 'Resend Pay by Link';
                    Image = SendMail;

                    trigger OnAction()
                    var
                        MagentoPmtAdyenMgt: Codeunit "NPR Magento Pmt. Adyen Mgt.";
                    begin
                        MagentoPmtAdyenMgt.ResendPayByLink(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetGatewayEnabled();
    end;

    var
#if not BC17
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
#endif
        CapturePaymentAgainQst: Label 'Payment has already been Captured\Capture Again?';
        CapturePaymentQst: Label 'Do you want to capture the payment?';
        CaptureEnabled: Boolean;
        RefundEnabled: Boolean;
        RefundPaymentAgainQst: Label 'Payment has already been Refunded\Refund Again?';
        RefundPaymentQst: Label 'Do you want to refund the payment?';
        CancelPaymentAgainQst: Label 'Payment has already been Canceled\Cancel Again?';
        CancelPaymentQst: Label 'Do you want to cancel the payment?';
        PaymentPostedMsg: Label 'Payment Posted';
        PostPaymentQst: Label 'Do you want to post the payment?';
        SkipPostingQst: Label 'Do you want to set Skip Posting?';
        CancelPayByLinkQst: Label 'Do you want to cancel the Pay by Link ?';
        ResetPostingErrQst: Label 'Do you want to reset posting errors?';

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
