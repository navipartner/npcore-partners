page 6151206 "NPR NpCs Coll. StoreOrder Card"
{
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
                    field("Document Type"; "Document Type")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Document No."; "Document No.")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Reference No."; "Reference No.")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Sell-to Customer Name"; "Sell-to Customer Name")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Location Code"; "Location Code")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Opening Hour Set"; "Opening Hour Set")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("From Document Type"; "From Document Type")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("From Document No."; "From Document No.")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("From Store Code"; "From Store Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Processing Status"; "Processing Status")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Promoted;
                    }
                    field("Processing Expiry Duration"; "Processing Expiry Duration")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Processing expires at"; "Processing expires at")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Processing updated at"; "Processing updated at")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Processing updated by"; "Processing updated by")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Additional;
                    }
                    field("Processing Print Template"; "Processing Print Template")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
                group(Control6014445)
                {
                    ShowCaption = false;
                    field("Delivery Status"; "Delivery Status")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Promoted;
                    }
                    field("Delivery Expiry Days (Qty.)"; "Delivery Expiry Days (Qty.)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Delivery expires at"; "Delivery expires at")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Delivery updated at"; "Delivery updated at")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Delivery updated by"; "Delivery updated by")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Additional;
                    }
                    field("Delivery Document Type"; "Delivery Document Type")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Delivery Document No."; "Delivery Document No.")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Archive on Delivery"; "Archive on Delivery")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Prepaid Amount"; "Prepaid Amount")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Additional;
                    }
                    field("Prepayment Account No."; "Prepayment Account No.")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Bill via"; "Bill via")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Post on"; "Post on")
                    {
                        ApplicationArea = All;
                    }
                    field("Store Stock"; "Store Stock")
                    {
                        ApplicationArea = All;
                        Style = Unfavorable;
                        StyleExpr = TRUE;
                    }
                    group(Control6014458)
                    {
                        ShowCaption = false;
                        Visible = "Bill via" = "Bill via"::POS;
                        field("Delivery Print Template (POS)"; "Delivery Print Template (POS)")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                        }
                    }
                    group(Control6014459)
                    {
                        ShowCaption = false;
                        Visible = "Bill via" = "Bill via"::"Sales Document";
                        field("Delivery Print Template (S.)"; "Delivery Print Template (S.)")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                        }
                    }
                    group(Control6014447)
                    {
                        ShowCaption = false;
                        Visible = NOT "Store Stock";
                        field("UPPERCASE(Text002)"; UpperCase(Text002))
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = Unfavorable;
                            StyleExpr = TRUE;
                        }
                    }
                }
            }
            group(Notification)
            {
                Caption = 'Notification';
                field("Send Notification from Store"; "Send Notification from Store")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                group(Control6014468)
                {
                    ShowCaption = false;
                    field("Notify Store via E-mail"; "Notify Store via E-mail")
                    {
                        ApplicationArea = All;
                    }
                    field("Store E-mail Temp. (Pending)"; "Store E-mail Temp. (Pending)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Store E-mail Temp. (Expired)"; "Store E-mail Temp. (Expired)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
                group(Control6014475)
                {
                    ShowCaption = false;
                    field("Notify Store via Sms"; "Notify Store via Sms")
                    {
                        ApplicationArea = All;
                    }
                    field("Store Sms Template (Pending)"; "Store Sms Template (Pending)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Store Sms Template (Expired)"; "Store Sms Template (Expired)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
                group(Control6014441)
                {
                    ShowCaption = false;
                    field("Notify Customer via E-mail"; "Notify Customer via E-mail")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Customer E-mail"; "Customer E-mail")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("E-mail Template (Pending)"; "E-mail Template (Pending)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("E-mail Template (Confirmed)"; "E-mail Template (Confirmed)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("E-mail Template (Rejected)"; "E-mail Template (Rejected)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("E-mail Template (Expired)"; "E-mail Template (Expired)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
                group(Control6014440)
                {
                    ShowCaption = false;
                    field("Notify Customer via Sms"; "Notify Customer via Sms")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Customer Phone No."; "Customer Phone No.")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Sms Template (Pending)"; "Sms Template (Pending)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Sms Template (Confirmed)"; "Sms Template (Confirmed)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Sms Template (Rejected)"; "Sms Template (Rejected)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Sms Template (Expired)"; "Sms Template (Expired)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
            }
            part(Control6014423; "NPR NpCs Coll. StoreOrderLines")
            {
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No.");
                Visible = "Document Type" = "Document Type"::Order;
                ApplicationArea = All;
            }
            part(Control6014464; "NPR NpCs Coll. Store Inv.Lines")
            {
                SubPageLink = "Document No." = FIELD("Document No.");
                Visible = "Document Type" = "Document Type"::"Posted Invoice";
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = "Processing Print Template" <> '';
                    ApplicationArea = All;

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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = "Document Type" = "Document Type"::Order;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        DocPrint: Codeunit "Document-Print";
                        Usage: Option "Order Confirmation","Work Order","Pick Instruction";
                    begin
                        SalesHeader.Get("Document Type", "Document No.");
                        DocPrint.PrintSalesOrder(SalesHeader, Usage::"Order Confirmation");
                    end;
                }
                action("Print Delivery")
                {
                    Caption = 'Print Delivery';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = ("Delivery Status" = "Delivery Status"::Delivered) AND ((("Bill via" = "Bill via"::POS) AND ("Delivery Print Template (POS)" <> '')) OR (("Bill via" = "Bill via"::"Sales Document") AND ("Delivery Print Template (S.)" <> '')));
                    ApplicationArea = All;

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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = (("Processing Status" = 0) OR ("Processing Status" = 1)) AND ("Delivery Status" = 0);
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                    begin
                        if not Confirm(Text000, true, "Document No.") then
                            exit;

                        NpCsCollectMgt.ConfirmProcessing(Rec);
                    end;
                }
                action("Reject Order")
                {
                    Caption = 'Reject Order';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = (("Processing Status" = 0) OR ("Processing Status" = 1)) AND ("Delivery Status" = 0) AND ("Store Stock");
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                    begin
                        if not Confirm(Text001, true, "Document No.") then
                            exit;

                        NpCsCollectMgt.RejectProcessing(Rec);
                    end;
                }
                action("Send Notification to Customer")
                {
                    Caption = 'Send Notification to Customer';
                    Image = SendTo;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = "Send Notification from Store";
                    ApplicationArea = All;

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
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F7';
                ApplicationArea = All;

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
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea = All;

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
        Reset;
    end;

    var
        Text000: Label 'Confirm Order %1?';
        Text001: Label 'Reject Order %1?';
        Text002: Label 'Do not pick from Store Stock';
}

