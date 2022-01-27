page 6151206 "NPR NpCs Coll. StoreOrder Card"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'Collect in Store Order Card';
    SourceTable = "NPR NpCs Document";
    SourceTableView = WHERE(Type = CONST("Collect in Store"));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control6014443)
                {
                    ShowCaption = false;
                    field("Document Type"; Rec."Document Type")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Document Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Document No."; Rec."Document No.")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Document No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Reference No."; Rec."Reference No.")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Reference No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ship-to Contact"; Rec."Ship-to Contact")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Ship-to Contact field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Location Code"; Rec."Location Code")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Location Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Opening Hour Set"; Rec."Opening Hour Set")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Opening Hour Set field';
                        ApplicationArea = NPRRetail;
                    }
                    field("From Document Type"; Rec."From Document Type")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the From Document Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("From Document No."; Rec."From Document No.")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the From Document No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("From Store Code"; Rec."From Store Code")
                    {

                        ToolTip = 'Specifies the value of the From Store Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Processing Status"; Rec."Processing Status")
                    {

                        Editable = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Processing Status field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Processing Expiry Duration"; Rec."Processing Expiry Duration")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Processing Expiry Duration field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Processing expires at"; Rec."Processing expires at")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Processing expires at field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Processing updated at"; Rec."Processing updated at")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Processing updated at field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Processing updated by"; Rec."Processing updated by")
                    {

                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Processing updated by field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Processing Print Template"; Rec."Processing Print Template")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Processing Print Template field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014445)
                {
                    ShowCaption = false;
                    field("Delivery Status"; Rec."Delivery Status")
                    {

                        Editable = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Delivery Status field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Delivery Expiry Days (Qty.)"; Rec."Delivery Expiry Days (Qty.)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Delivery Expiry Days (Qty.) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Delivery expires at"; Rec."Delivery expires at")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Delivery expires at field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Delivery updated at"; Rec."Delivery updated at")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Delivery updated at field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Delivery updated by"; Rec."Delivery updated by")
                    {

                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Delivery updated by field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Delivery Document Type"; Rec."Delivery Document Type")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Delivery Document Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Delivery Document No."; Rec."Delivery Document No.")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Delivery Document No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Archive on Delivery"; Rec."Archive on Delivery")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Archive on Delivery field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Prepaid Amount"; Rec."Prepaid Amount")
                    {

                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Prepaid Amount field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Prepayment Account No."; Rec."Prepayment Account No.")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Prepayment Account No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bill via"; Rec."Bill via")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Bill via field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Post on"; Rec."Post on")
                    {

                        ToolTip = 'Specifies the value of the Post on field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Store Stock"; Rec."Store Stock")
                    {

                        Style = Unfavorable;
                        StyleExpr = TRUE;
                        ToolTip = 'Specifies the value of the Store Stock field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6014458)
                    {
                        ShowCaption = false;
                        Visible = Rec."Bill via" = Rec."Bill via"::POS;
                        field("Delivery Print Template (POS)"; Rec."Delivery Print Template (POS)")
                        {

                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Delivery Print Template (POS) field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control6014459)
                    {
                        ShowCaption = false;
                        Visible = Rec."Bill via" = Rec."Bill via"::"Sales Document";
                        field("Delivery Print Template (S.)"; Rec."Delivery Print Template (S.)")
                        {

                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Delivery Template (Sales Document) field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control6014447)
                    {
                        ShowCaption = false;
                        Visible = NOT Rec."Store Stock";
                        field(WarningText; UpperCase(Text002))
                        {

                            ShowCaption = false;
                            Style = Unfavorable;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the value of the UpperCase(Text002) field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
            group(Notification)
            {
                Caption = 'Notification';
                field("Send Notification from Store"; Rec."Send Notification from Store")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                    ApplicationArea = NPRRetail;
                }
                group(Control6014468)
                {
                    ShowCaption = false;
                    field("Notify Store via E-mail"; Rec."Notify Store via E-mail")
                    {

                        ToolTip = 'Specifies the value of the Notify Store via E-mail field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Store E-mail Temp. (Pending)"; Rec."Store E-mail Temp. (Pending)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Store E-mail Template (Pending) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Store E-mail Temp. (Expired)"; Rec."Store E-mail Temp. (Expired)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Store E-mail Template (Expired) field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014475)
                {
                    ShowCaption = false;
                    field("Notify Store via Sms"; Rec."Notify Store via Sms")
                    {

                        ToolTip = 'Specifies the value of the Notify Store via Sms field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Store Sms Template (Pending)"; Rec."Store Sms Template (Pending)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Store Sms Template (Pending) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Store Sms Template (Expired)"; Rec."Store Sms Template (Expired)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Store Sms Template (Expired) field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014441)
                {
                    ShowCaption = false;
                    field("Notify Customer via E-mail"; Rec."Notify Customer via E-mail")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Notify Customer via E-mail field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer E-mail"; Rec."Customer E-mail")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Customer E-mail field';
                        ApplicationArea = NPRRetail;
                    }
                    field("E-mail Template (Pending)"; Rec."E-mail Template (Pending)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the E-mail Template (Pending) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("E-mail Template (Confirmed)"; Rec."E-mail Template (Confirmed)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the E-mail Template (Confirmed) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("E-mail Template (Rejected)"; Rec."E-mail Template (Rejected)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the E-mail Template (Rejected) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("E-mail Template (Expired)"; Rec."E-mail Template (Expired)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the E-mail Template (Expired) field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014440)
                {
                    ShowCaption = false;
                    field("Notify Customer via Sms"; Rec."Notify Customer via Sms")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Notify Customer via Sms field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer Phone No."; Rec."Customer Phone No.")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Customer Phone No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sms Template (Pending)"; Rec."Sms Template (Pending)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Sms Template (Pending) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sms Template (Confirmed)"; Rec."Sms Template (Confirmed)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Sms Template (Confirmed) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sms Template (Rejected)"; Rec."Sms Template (Rejected)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Sms Template (Rejected) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sms Template (Expired)"; Rec."Sms Template (Expired)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Sms Template (Expired) field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            part(Control6014423; "NPR NpCs Coll. StoreOrderLines")
            {
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No.");
                Visible = Rec."Document Type" = Rec."Document Type"::Order;
                ApplicationArea = NPRRetail;

            }
            part(Control6014464; "NPR NpCs Coll. Store Inv.Lines")
            {
                SubPageLink = "Document No." = FIELD("Document No.");
                Visible = Rec."Document Type" = Rec."Document Type"::"Posted Invoice";
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Print")
            {
                Caption = '&Print';
                Image = Print;
                action("Print Order")
                {
                    Caption = 'Print Order';
                    Image = ConfirmAndPrint;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = Rec."Processing Print Template" <> '';

                    ToolTip = 'Executes the Print Order action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                    begin
                        NpCsCollectMgt.PrintOrder(Rec);
                    end;
                }
                action("Print Confirmation")
                {
                    Caption = 'Print Confirmation';
                    Ellipsis = true;
                    Image = PrintReport;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = Rec."Document Type" = Rec."Document Type"::Order;

                    ToolTip = 'Executes the Print Confirmation action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        DocPrint: Codeunit "Document-Print";
                        Usage: Option "Order Confirmation","Work Order","Pick Instruction";
                    begin
                        SalesHeader.Get(Rec."Document Type", Rec."Document No.");
                        DocPrint.PrintSalesOrder(SalesHeader, Usage::"Order Confirmation");
                    end;
                }
                action("Print Delivery")
                {
                    Caption = 'Print Delivery';
                    Image = Print;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = (Rec."Delivery Status" = Rec."Delivery Status"::Delivered) AND (((Rec."Bill via" = Rec."Bill via"::POS) AND (Rec."Delivery Print Template (POS)" <> '')) OR ((Rec."Bill via" = Rec."Bill via"::"Sales Document") AND (Rec."Delivery Print Template (S.)" <> '')));

                    ToolTip = 'Executes the Print Delivery action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                    begin
                        NpCsCollectMgt.PrintDelivery(Rec);
                    end;
                }
            }
            group("Order Processing")
            {
                Caption = 'Order Processing';
                action("Confirm Order")
                {
                    Caption = 'Confirm Order';
                    Image = Approve;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = ((Rec."Processing Status" = 0) OR (Rec."Processing Status" = 1)) AND (Rec."Delivery Status" = 0);

                    ToolTip = 'Executes the Confirm Order action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                    begin
                        if not Confirm(Text000, true, Rec."Document No.") then
                            exit;

                        NpCsCollectMgt.ConfirmProcessing(Rec);
                    end;
                }
                action("Reject Order")
                {
                    Caption = 'Reject Order';
                    Image = Reject;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = ((Rec."Processing Status" = 0) OR (Rec."Processing Status" = 1)) AND (Rec."Delivery Status" = 0) AND (Rec."Store Stock");

                    ToolTip = 'Executes the Reject Order action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                    begin
                        if not Confirm(Text001, true, Rec."Document No.") then
                            exit;

                        NpCsCollectMgt.RejectProcessing(Rec);
                    end;
                }
                action("Send Notification to Customer")
                {
                    Caption = 'Send Notification to Customer';
                    Image = SendTo;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = Rec."Send Notification from Store";

                    ToolTip = 'Executes the Send Notification to Customer action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        NpCsWorkflowMgt.SendNotificationToCustomer(Rec);
                    end;
                }
            }
        }
        area(navigation)
        {
            action(Document)
            {
                Caption = 'Document';
                Image = Document;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F7';

                ToolTip = 'Executes the Document action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                begin
                    NpCsCollectMgt.RunDocumentCard(Rec);
                end;
            }
            action("Log Entries")
            {
                Caption = 'Log Entries';
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+F7';

                ToolTip = 'Executes the Log Entries action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                begin
                    NpCsCollectMgt.RunLog(Rec, false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
    end;

    var
        Text000: Label 'Confirm Order %1?';
        Text001: Label 'Reject Order %1?';
        Text002: Label 'Do not pick from Store Stock';
}

