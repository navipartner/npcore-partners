page 6151206 "NpCs Collect Store Order Card"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect in Store Order Card';
    SourceTable = "NpCs Document";
    SourceTableView = WHERE(Type=CONST("Collect in Store"));

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
                    field("Document No.";"Document No.")
                    {
                        Importance = Additional;
                    }
                    field("Reference No.";"Reference No.")
                    {
                        Importance = Promoted;
                    }
                    field("Sell-to Customer Name";"Sell-to Customer Name")
                    {
                        Importance = Promoted;
                    }
                    field("Location Code";"Location Code")
                    {
                        Importance = Additional;
                    }
                    field("From Document Type";"From Document Type")
                    {
                        Importance = Additional;
                    }
                    field("From Document No.";"From Document No.")
                    {
                        Importance = Additional;
                    }
                    field("From Store Code";"From Store Code")
                    {
                    }
                    field("Processing Status";"Processing Status")
                    {
                        Editable = false;
                        Importance = Promoted;
                    }
                    field("Processing updated at";"Processing updated at")
                    {
                        Editable = false;
                    }
                    field("Processing updated by";"Processing updated by")
                    {
                        Editable = false;
                        Importance = Additional;
                    }
                }
                group(Control6014445)
                {
                    ShowCaption = false;
                    field("Delivery Status";"Delivery Status")
                    {
                        Editable = false;
                        Importance = Promoted;
                    }
                    field("Delivery updated at";"Delivery updated at")
                    {
                        Editable = false;
                    }
                    field("Delivery updated by";"Delivery updated by")
                    {
                        Editable = false;
                        Importance = Additional;
                    }
                    field("Delivery Document Type";"Delivery Document Type")
                    {
                        Importance = Additional;
                    }
                    field("Delivery Document No.";"Delivery Document No.")
                    {
                        Importance = Additional;
                    }
                    field("Prepaid Amount";"Prepaid Amount")
                    {
                        Editable = false;
                        Importance = Additional;
                    }
                    field("Prepayment Account No.";"Prepayment Account No.")
                    {
                        Importance = Additional;
                    }
                    field("Bill via";"Bill via")
                    {
                        Importance = Additional;
                    }
                    field("Delivery Only (Non stock)";"Delivery Only (Non stock)")
                    {
                        Style = Unfavorable;
                        StyleExpr = TRUE;
                    }
                    group(Control6014447)
                    {
                        ShowCaption = false;
                        Visible = "Delivery Only (Non stock)";
                        field("UPPERCASE(FIELDCAPTION(""Delivery Only (Non stock)""))";UpperCase(FieldCaption("Delivery Only (Non stock)")))
                        {
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
                field("Send Notification from Store";"Send Notification from Store")
                {
                    Importance = Promoted;
                }
                group(Control6014441)
                {
                    ShowCaption = false;
                    field("Notify Customer via E-mail";"Notify Customer via E-mail")
                    {
                        Importance = Promoted;
                    }
                    field("Customer E-mail";"Customer E-mail")
                    {
                        Importance = Promoted;
                    }
                    field("E-mail Template (Pending)";"E-mail Template (Pending)")
                    {
                        Importance = Additional;
                    }
                    field("E-mail Template (Confirmed)";"E-mail Template (Confirmed)")
                    {
                        Importance = Additional;
                    }
                    field("E-mail Template (Rejected)";"E-mail Template (Rejected)")
                    {
                        Importance = Additional;
                    }
                    field("E-mail Template (Expired)";"E-mail Template (Expired)")
                    {
                        Importance = Additional;
                    }
                }
                group(Control6014440)
                {
                    ShowCaption = false;
                    field("Notify Customer via Sms";"Notify Customer via Sms")
                    {
                        Importance = Promoted;
                    }
                    field("Customer Phone No.";"Customer Phone No.")
                    {
                        Importance = Promoted;
                    }
                    field("Sms Template (Pending)";"Sms Template (Pending)")
                    {
                        Importance = Additional;
                    }
                    field("Sms Template (Confirmed)";"Sms Template (Confirmed)")
                    {
                        Importance = Additional;
                    }
                    field("Sms Template (Rejected)";"Sms Template (Rejected)")
                    {
                        Importance = Additional;
                    }
                    field("Sms Template (Expired)";"Sms Template (Expired)")
                    {
                        Importance = Additional;
                    }
                }
            }
            part(Control6014423;"NpCs Collect Store Order Lines")
            {
                SubPageLink = "Document Type"=FIELD("Document Type"),
                              "Document No."=FIELD("Document No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
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
                    Visible = ("Processing Status" = 1) AND ("Delivery Status" = 0);

                    trigger OnAction()
                    var
                        NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
                    begin
                        if not Confirm(Text000,true,"Document No.") then
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
                    Visible = ("Processing Status" = 1) AND ("Delivery Status" = 0) AND (NOT "Delivery Only (Non stock)");

                    trigger OnAction()
                    var
                        NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
                    begin
                        if not Confirm(Text001,true,"Document No.") then
                          exit;

                        NpCsCollectMgt.RejectProcessing(Rec);
                    end;
                }
                action("Send Notification to Customer")
                {
                    Caption = 'Send Notification to Customer';
                    Image = SendTo;
                    Visible = "Send Notification from Store";

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
                    begin
                        NpCsWorkflowMgt.SendNotificationToCustomer(Rec);
                    end;
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                Image = Print;
                action(Print)
                {
                    Caption = 'Print';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
                    begin
                        NpCsCollectMgt.PrintDelivery(Rec);
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

                trigger OnAction()
                var
                    NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
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

                trigger OnAction()
                var
                    NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
                begin
                    NpCsCollectMgt.RunLog(Rec,false);
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
}

