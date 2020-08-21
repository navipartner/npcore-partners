page 6151454 "Magento Payment Line List"
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
    SourceTable = "Magento Payment Line";
    UsageCategory = Lists;

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
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Payment Type"; "Payment Type")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = All;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Allow Adjust Amount"; "Allow Adjust Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field(Posted; Posted)
                {
                    ApplicationArea = All;
                }
                field("Payment Gateway Code"; "Payment Gateway Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("External Reference No."; "External Reference No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Date Captured"; "Date Captured")
                {
                    ApplicationArea = All;
                }
                field("Date Refunded"; "Date Refunded")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control50000; Notes)
            {
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = CaptureEnabled;

                trigger OnAction()
                var
                    MagentoPaymentGateway: Record "Magento Payment Gateway";
                    MagentoPmtMgt: Codeunit "Magento Pmt. Mgt.";
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = RefundEnabled;

                trigger OnAction()
                var
                    MagentoPaymentGateway: Record "Magento Payment Gateway";
                    MagentoPmtMgt: Codeunit "Magento Pmt. Mgt.";
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ("Document Table No." = 112) AND ("Account No." <> '') AND (NOT Posted);

                trigger OnAction()
                var
                    GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
                    MagentoPmtMgt: Codeunit "Magento Pmt. Mgt.";
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ("Document Table No." = 112) OR ("Document Table No." = 114);

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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MagentoPmtMgt: Codeunit "Magento Pmt. Mgt.";
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
        PaymentGateway: Record "Magento Payment Gateway";
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

