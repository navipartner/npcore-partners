page 6151205 "NpCs Collect Store Orders"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // #344264/MHA /20190717  CASE 344264 Added Last Log fields and changed name and logic for field 240 to "From Store Stock"
    // #362443/MHA /20190719  CASE 362443 Added "Inserted at" changed Visible on some fields
    // #364557/MHA /20190819  CASE 364557 Removed InsertAllowed

    Caption = 'Collect in Store Orders';
    CardPageID = "NpCs Collect Store Order Card";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NpCs Document";
    SourceTableView = SORTING("Entry No.")
                      WHERE(Type=CONST("Collect in Store"),
                            "Document Type"=FILTER(Order|"Posted Invoice"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No.";"Document No.")
                {
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        RunCard();
                    end;
                }
                field("Reference No.";"Reference No.")
                {

                    trigger OnDrillDown()
                    begin
                        RunCard();
                    end;
                }
                field("Sell-to Customer Name";"Sell-to Customer Name")
                {

                    trigger OnDrillDown()
                    begin
                        RunCard();
                    end;
                }
                field("Inserted at";"Inserted at")
                {
                }
                field("Location Code";"Location Code")
                {

                    trigger OnDrillDown()
                    begin
                        RunCard();
                    end;
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field("From Document Type";"From Document Type")
                {
                    Visible = false;
                }
                field("From Document No.";"From Document No.")
                {
                    Visible = false;
                }
                field("From Store Code";"From Store Code")
                {
                    Visible = false;
                }
                field("Processing Status";"Processing Status")
                {
                }
                field("Processing updated at";"Processing updated at")
                {
                }
                field("Processing updated by";"Processing updated by")
                {
                    Visible = false;
                }
                field("Customer No.";"Customer No.")
                {
                }
                field("Customer E-mail";"Customer E-mail")
                {
                }
                field("Customer Phone No.";"Customer Phone No.")
                {
                }
                field("Send Notification from Store";"Send Notification from Store")
                {
                    Visible = false;
                }
                field("Notify Customer via E-mail";"Notify Customer via E-mail")
                {
                    Visible = false;
                }
                field("Notify Customer via Sms";"Notify Customer via Sms")
                {
                    Visible = false;
                }
                field("Store Stock";"Store Stock")
                {
                }
                field("Delivery Status";"Delivery Status")
                {
                }
                field("Delivery updated at";"Delivery updated at")
                {
                    Visible = false;
                }
                field("Delivery updated by";"Delivery updated by")
                {
                    Visible = false;
                }
                field("Prepaid Amount";"Prepaid Amount")
                {
                    Visible = false;
                }
                field("Prepayment Account No.";"Prepayment Account No.")
                {
                    Visible = false;
                }
                field("Delivery Document Type";"Delivery Document Type")
                {
                    Visible = false;
                }
                field("Delivery Document No.";"Delivery Document No.")
                {
                    Visible = false;
                }
                field("Archive on Delivery";"Archive on Delivery")
                {
                    Visible = false;
                }
                field(LastLogMessage;GetLastLogMessage())
                {
                    Caption = 'Last Log Message';
                }
                field(LastLogErrorMessage;GetLastLogErrorMessage())
                {
                    Caption = 'Last Log Error Message';
                    Style = Attention;
                    StyleExpr = TRUE;
                }
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

                    trigger OnAction()
                    var
                        NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
                    begin
                        //-#364557 [364557]
                        NpCsCollectMgt.PrintOrder(Rec);
                        //+#364557 [364557]
                    end;
                }
                action("Print Delivery")
                {
                    Caption = 'Print Delivery';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = ("Delivery Status" = "Delivery Status"::Delivered) AND ((("Bill via" = "Bill via"::POS) AND ("Delivery Print Template (POS)" <>'')) OR (("Bill via" = "Bill via"::"Sales Document") AND ("Delivery Print Template (S.)" <>'')));

                    trigger OnAction()
                    var
                        NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
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
                    Visible = ("Processing Status" = 1) AND ("Delivery Status" = 0) AND ("Store Stock");

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
                action(Archive)
                {
                    Caption = 'Archive';
                    Image = Archive;

                    trigger OnAction()
                    var
                        NpCsArchCollectMgt: Codeunit "NpCs Arch. Collect Mgt.";
                    begin
                        if ("Processing Status" in ["Processing Status"::" ","Processing Status"::Pending,"Processing Status"::Confirmed]) and
                          ("Delivery Status" in ["Delivery Status"::" ","Delivery Status"::Ready])
                        then begin
                          if not Confirm(Text002,false,"Document Type","Document No.") then
                            exit;
                        end;
                        //-#344264 [344264]
                        if NpCsArchCollectMgt.ArchiveCollectDocument(Rec) then
                        //+#344264 [344264]
                          Message(Text003,"Document Type","Reference No.")
                        else
                          Message(Text004,"Document Type","Reference No.",GetLastErrorText);

                        CurrPage.Update(false);
                    end;
                }
            }
            group(Callback)
            {
                Caption = 'Callback';
                action("Invoke Callback")
                {
                    Caption = 'Invoke Callback';
                    Image = UpdateShipment;
                    Visible = HasCallback;

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
                    begin
                        NpCsWorkflowMgt.RunCallback(Rec);
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

    trigger OnAfterGetCurrRecord()
    begin
        HasCallback := "Callback Data".HasValue;
    end;

    var
        Text000: Label 'Confirm Order %1?';
        Text001: Label 'Reject Order %1?';
        HasCallback: Boolean;
        Text002: Label 'Collect %1 %2 has not been delivered.\\Archive anyway?';
        Text003: Label 'Collect %1 %2 has been archived.';
        Text004: Label 'Collect %1 %2 could not be archived:\\%3';

    local procedure RunCard()
    begin
        PAGE.Run(PAGE::"NpCs Collect Store Order Card",Rec);
    end;
}

