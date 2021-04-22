page 6151206 "NPR NpCs Coll. StoreOrder Card"
{
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
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Document Type field';
                    }
                    field("Document No."; Rec."Document No.")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Document No. field';
                    }
                    field("Reference No."; Rec."Reference No.")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Reference No. field';
                    }
                    field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                    }
                    field("Ship-to Contact"; Rec."Ship-to Contact")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Ship-to Contact field';
                    }
                    field("Location Code"; Rec."Location Code")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Location Code field';
                    }
                    field("Opening Hour Set"; Rec."Opening Hour Set")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Opening Hour Set field';
                    }
                    field("From Document Type"; Rec."From Document Type")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the From Document Type field';
                    }
                    field("From Document No."; Rec."From Document No.")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the From Document No. field';
                    }
                    field("From Store Code"; Rec."From Store Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the From Store Code field';
                    }
                    field("Processing Status"; Rec."Processing Status")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Processing Status field';
                    }
                    field("Processing Expiry Duration"; Rec."Processing Expiry Duration")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Processing Expiry Duration field';
                    }
                    field("Processing expires at"; Rec."Processing expires at")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Processing expires at field';
                    }
                    field("Processing updated at"; Rec."Processing updated at")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Processing updated at field';
                    }
                    field("Processing updated by"; Rec."Processing updated by")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Processing updated by field';
                    }
                    field("Processing Print Template"; Rec."Processing Print Template")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Processing Print Template field';
                    }
                }
                group(Control6014445)
                {
                    ShowCaption = false;
                    field("Delivery Status"; Rec."Delivery Status")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Delivery Status field';
                    }
                    field("Delivery Expiry Days (Qty.)"; Rec."Delivery Expiry Days (Qty.)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Delivery Expiry Days (Qty.) field';
                    }
                    field("Delivery expires at"; Rec."Delivery expires at")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Delivery expires at field';
                    }
                    field("Delivery updated at"; Rec."Delivery updated at")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Delivery updated at field';
                    }
                    field("Delivery updated by"; Rec."Delivery updated by")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Delivery updated by field';
                    }
                    field("Delivery Document Type"; Rec."Delivery Document Type")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Delivery Document Type field';
                    }
                    field("Delivery Document No."; Rec."Delivery Document No.")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Delivery Document No. field';
                    }
                    field("Archive on Delivery"; Rec."Archive on Delivery")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Archive on Delivery field';
                    }
                    field("Prepaid Amount"; Rec."Prepaid Amount")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Prepaid Amount field';
                    }
                    field("Prepayment Account No."; Rec."Prepayment Account No.")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Prepayment Account No. field';
                    }
                    field("Bill via"; Rec."Bill via")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Bill via field';
                    }
                    field("Post on"; Rec."Post on")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post on field';
                    }
                    field("Store Stock"; Rec."Store Stock")
                    {
                        ApplicationArea = All;
                        Style = Unfavorable;
                        StyleExpr = TRUE;
                        ToolTip = 'Specifies the value of the Store Stock field';
                    }
                    group(Control6014458)
                    {
                        ShowCaption = false;
                        Visible = Rec."Bill via" = Rec."Bill via"::POS;
                        field("Delivery Print Template (POS)"; Rec."Delivery Print Template (POS)")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Delivery Print Template (POS) field';
                        }
                    }
                    group(Control6014459)
                    {
                        ShowCaption = false;
                        Visible = Rec."Bill via" = Rec."Bill via"::"Sales Document";
                        field("Delivery Print Template (S.)"; Rec."Delivery Print Template (S.)")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Delivery Template (Sales Document) field';
                        }
                    }
                    group(Control6014447)
                    {
                        ShowCaption = false;
                        Visible = NOT Rec."Store Stock";
                        field("UPPERCASE(Text002)"; UpperCase(Text002))
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = Unfavorable;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the value of the UpperCase(Text002) field';
                        }
                    }
                }
            }
            group(Notification)
            {
                Caption = 'Notification';
                field("Send Notification from Store"; Rec."Send Notification from Store")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                }
                group(Control6014468)
                {
                    ShowCaption = false;
                    field("Notify Store via E-mail"; Rec."Notify Store via E-mail")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Notify Store via E-mail field';
                    }
                    field("Store E-mail Temp. (Pending)"; Rec."Store E-mail Temp. (Pending)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Store E-mail Template (Pending) field';
                    }
                    field("Store E-mail Temp. (Expired)"; Rec."Store E-mail Temp. (Expired)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Store E-mail Template (Expired) field';
                    }
                }
                group(Control6014475)
                {
                    ShowCaption = false;
                    field("Notify Store via Sms"; Rec."Notify Store via Sms")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Notify Store via Sms field';
                    }
                    field("Store Sms Template (Pending)"; Rec."Store Sms Template (Pending)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Store Sms Template (Pending) field';
                    }
                    field("Store Sms Template (Expired)"; Rec."Store Sms Template (Expired)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Store Sms Template (Expired) field';
                    }
                }
                group(Control6014441)
                {
                    ShowCaption = false;
                    field("Notify Customer via E-mail"; Rec."Notify Customer via E-mail")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Notify Customer via E-mail field';
                    }
                    field("Customer E-mail"; Rec."Customer E-mail")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Customer E-mail field';
                    }
                    field("E-mail Template (Pending)"; Rec."E-mail Template (Pending)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the E-mail Template (Pending) field';
                    }
                    field("E-mail Template (Confirmed)"; Rec."E-mail Template (Confirmed)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the E-mail Template (Confirmed) field';
                    }
                    field("E-mail Template (Rejected)"; Rec."E-mail Template (Rejected)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the E-mail Template (Rejected) field';
                    }
                    field("E-mail Template (Expired)"; Rec."E-mail Template (Expired)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the E-mail Template (Expired) field';
                    }
                }
                group(Control6014440)
                {
                    ShowCaption = false;
                    field("Notify Customer via Sms"; Rec."Notify Customer via Sms")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Notify Customer via Sms field';
                    }
                    field("Customer Phone No."; Rec."Customer Phone No.")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Customer Phone No. field';
                    }
                    field("Sms Template (Pending)"; Rec."Sms Template (Pending)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Sms Template (Pending) field';
                    }
                    field("Sms Template (Confirmed)"; Rec."Sms Template (Confirmed)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Sms Template (Confirmed) field';
                    }
                    field("Sms Template (Rejected)"; Rec."Sms Template (Rejected)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Sms Template (Rejected) field';
                    }
                    field("Sms Template (Expired)"; Rec."Sms Template (Expired)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Sms Template (Expired) field';
                    }
                }
            }
            part(Control6014423; "NPR NpCs Coll. StoreOrderLines")
            {
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No.");
                Visible = Rec."Document Type" = Rec."Document Type"::Order;
                ApplicationArea = All;
            }
            part(Control6014464; "NPR NpCs Coll. Store Inv.Lines")
            {
                SubPageLink = "Document No." = FIELD("Document No.");
                Visible = Rec."Document Type" = Rec."Document Type"::"Posted Invoice";
                ApplicationArea = All;
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print Order action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print Confirmation action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print Delivery action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Confirm Order action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Reject Order action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send Notification to Customer action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Document action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Log Entries action';

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

