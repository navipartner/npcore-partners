page 6151205 "NPR NpCs Coll. Store Orders"
{
    Caption = 'Collect in Store Orders';
    CardPageID = "NPR NpCs Coll. StoreOrder Card";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NPR NpCs Document";
    SourceTableView = WHERE(Type = CONST("Collect in Store"),
                            "Document Type" = FILTER(Order | "Posted Invoice"));
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document No. field';

                    trigger OnDrillDown()
                    begin
                        RunCard();
                    end;
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';

                    trigger OnDrillDown()
                    begin
                        RunCard();
                    end;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to Customer Name field';

                    trigger OnDrillDown()
                    begin
                        RunCard();
                    end;
                }
                field("Inserted at"; Rec."Inserted at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inserted at field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';

                    trigger OnDrillDown()
                    begin
                        RunCard();
                    end;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("From Document Type"; Rec."From Document Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the From Document Type field';
                }
                field("From Document No."; Rec."From Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the From Document No. field';
                }
                field("From Store Code"; Rec."From Store Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the From Store Code field';
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Status field';
                }
                field("Processing updated at"; Rec."Processing updated at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing updated at field';
                }
                field("Processing updated by"; Rec."Processing updated by")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Processing updated by field';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Customer E-mail"; Rec."Customer E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer E-mail field';
                }
                field("Customer Phone No."; Rec."Customer Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Phone No. field';
                }
                field("Send Notification from Store"; Rec."Send Notification from Store")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                }
                field("Notify Customer via E-mail"; Rec."Notify Customer via E-mail")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Notify Customer via E-mail field';
                }
                field("Notify Customer via Sms"; Rec."Notify Customer via Sms")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Notify Customer via Sms field';
                }
                field("Store Stock"; Rec."Store Stock")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Stock field';
                }
                field("Delivery Status"; Rec."Delivery Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Status field';
                }
                field("Delivery updated at"; Rec."Delivery updated at")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Delivery updated at field';
                }
                field("Delivery updated by"; Rec."Delivery updated by")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Delivery updated by field';
                }
                field("Prepaid Amount"; Rec."Prepaid Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Prepaid Amount field';
                }
                field("Prepayment Account No."; Rec."Prepayment Account No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Prepayment Account No. field';
                }
                field("Delivery Document Type"; Rec."Delivery Document Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Delivery Document Type field';
                }
                field("Delivery Document No."; Rec."Delivery Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Delivery Document No. field';
                }
                field("Archive on Delivery"; Rec."Archive on Delivery")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Archive on Delivery field';
                }
                field(LastLogMessage; Rec.GetLastLogMessage())
                {
                    ApplicationArea = All;
                    Caption = 'Last Log Message';
                    ToolTip = 'Specifies the value of the Last Log Message field';
                }
                field(LastLogErrorMessage; Rec.GetLastLogErrorMessage())
                {
                    ApplicationArea = All;
                    Caption = 'Last Log Error Message';
                    Style = Attention;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the value of the Last Log Error Message field';
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
                        NpCsDocument: Record "NPR NpCs Document";
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(NpCsDocument);
                        if NpCsDocument.FindSet(true) then
                            repeat
                                NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
                                Commit();
                            until NpCsDocument.Next() = 0;
                    end;
                }
                action(Archive)
                {
                    Caption = 'Archive';
                    Image = Archive;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Archive action';

                    trigger OnAction()
                    var
                        NpCsArchCollectMgt: Codeunit "NPR NpCs Arch. Collect Mgt.";
                    begin
                        if (Rec."Processing Status" in [Rec."Processing Status"::" ", Rec."Processing Status"::Pending, Rec."Processing Status"::Confirmed]) and
                          (Rec."Delivery Status" in [Rec."Delivery Status"::" ", Rec."Delivery Status"::Ready])
                        then begin
                            if not Confirm(Text002, false, Rec."Document Type", Rec."Document No.") then
                                exit;
                        end;
                        if NpCsArchCollectMgt.ArchiveCollectDocument(Rec) then
                            Message(Text003, Rec."Document Type", Rec."Reference No.")
                        else
                            Message(Text004, Rec."Document Type", Rec."Reference No.", GetLastErrorText);

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Invoke Callback action';

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
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

    trigger OnAfterGetCurrRecord()
    begin
        HasCallback := Rec."Callback Data".HasValue();
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
        PAGE.Run(PAGE::"NPR NpCs Coll. StoreOrder Card", Rec);
    end;
}

