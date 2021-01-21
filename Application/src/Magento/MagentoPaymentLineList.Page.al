page 6151454 "NPR Magento Payment Line List"
{
    // MAG1.03/MHA /20150113  CASE 199932 Object created
    // MAG1.20/TR  /20150828  CASE  219645 Date Captured field updated
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/MHA /20160928  CASE 242561 Action Capture Payment changed from Visible if Table = 112 to always
    // MAG2.01/MHA /20160928  CASE 250694 Added field 110 "Date Refunded" and Action Refund Payment
    // MAG2.01/MHA /20161031  CASE 256733 Added Actions "Post Payment" and "Document Card"
    // MAG2.05/MHA /20170712  CASE 283588 Added field 90 "Allow Adjust Payment Amount"
    // MAG2.07/MHA /20170912  CASE 289527 "Posted" made editable and added AutoSplitKey

    AutoSplitKey = true;
    Caption = 'Payment Line List';
    PageType = List;
    SourceTable = "NPR Magento Payment Line";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Table No."; "Document Table No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document Table No. field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Payment Type"; "Payment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Type field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Type field';
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account No. field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Allow Adjust Amount"; "Allow Adjust Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Allow Adjust Amount field';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field(Posted; Posted)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posted field';
                }
                field("Payment Gateway Code"; "Payment Gateway Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Payment Gateway Code field';
                }
                field("External Reference No."; "External Reference No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the External Reference No. field';
                }
                field("Date Captured"; "Date Captured")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Captured field';
                }
                field("Date Refunded"; "Date Refunded")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Date Refunded field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control50000; Notes)
            {
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Capture Payment action';

                trigger OnAction()
                var
                    MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
                    MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
                begin
                    if "Date Captured" <> 0D then begin
                        //-MAG2.01 [242561]
                        //MESSAGE(Text002);
                        //EXIT;
                        if not Confirm(Text002, false) then
                            exit;
                        Rec."Date Captured" := 0D;
                        CurrPage.Update(true);
                        //+MAG2.01 [242561]
                    end;

                    MagentoPaymentGateway.Get("Payment Gateway Code");
                    MagentoPaymentGateway.TestField("Capture Codeunit Id");

                    MagentoPmtMgt.CapturePaymentLine(Rec);
                    //-MAG2.01 [242561]
                    //MESSAGE(Text001,"Payment Gateway Code","No.");
                    if "Date Captured" <> 0D then
                        Message(Text001, "Payment Gateway Code", "No.");
                    //+MAG2.01 [242561]
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
                ApplicationArea = All;
                ToolTip = 'Executes the Refund Payment action';

                trigger OnAction()
                var
                    MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
                    MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
                begin
                    //-MAG2.01 [242561]
                    if "Date Refunded" <> 0D then begin
                        if not Confirm(Text003, false) then
                            exit;
                        Rec."Date Refunded" := 0D;
                        CurrPage.Update(true);
                    end;

                    MagentoPaymentGateway.Get("Payment Gateway Code");
                    MagentoPaymentGateway.TestField("Capture Codeunit Id");

                    MagentoPmtMgt.RefundPaymentLine(Rec);
                    if "Date Refunded" <> 0D then
                        Message(Text000, "Payment Gateway Code", "No.");
                    //+MAG2.01 [242561]
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
                Visible = ("Document Table No." = 112) AND ("Account No." <> '') AND (NOT Posted);
                ApplicationArea = All;
                ToolTip = 'Executes the Post Payment action';

                trigger OnAction()
                var
                    GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
                    MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
                begin
                    //-MAG2.01 [256733]
                    MagentoPmtMgt.PostPaymentLine(Rec, GenJnlPostLine);
                    Message(Text004);
                    //+MAG2.01 [256733]
                end;
            }
        }
        area(navigation)
        {
            action(Navigate)
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ("Document Table No." = 112) OR ("Document Table No." = 114);
                ApplicationArea = All;
                ToolTip = 'Executes the &Navigate action';

                trigger OnAction()
                var
                    NavigateForm: Page Navigate;
                begin
                    NavigateForm.SetDoc("Posting Date", "Document No.");
                    NavigateForm.Run;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Document Card action';

                trigger OnAction()
                var
                    MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
                begin
                    //-MAG2.01 [256733]
                    MagentoPmtMgt.ShowDocumentCard(Rec);
                    //-MAG2.01 [256733]
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-MAG2.01 [250694]
        SetGatewayEnabled();
        //+MAG2.01 [250694]
    end;

    var
        Text000: Label 'Payment Refunded: %1 %2';
        Text001: Label 'Payment Captured: %1 %2';
        Text002: Label 'Payment has already been Captured\Capture Again?';
        CaptureEnabled: Boolean;
        RefundEnabled: Boolean;
        Text003: Label 'Payment has already been Refunded\Refund Again?';
        Text004: Label 'Payment Posted';

    local procedure SetGatewayEnabled()
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        //-MAG2.01 [250694]
        CaptureEnabled := false;
        RefundEnabled := false;
        if "Payment Gateway Code" = '' then
            exit;
        if not PaymentGateway.Get("Payment Gateway Code") then
            exit;
        CaptureEnabled := PaymentGateway."Capture Codeunit Id" <> 0;
        RefundEnabled := PaymentGateway."Refund Codeunit Id" <> 0;
        //+MAG2.01 [250694]
    end;
}

