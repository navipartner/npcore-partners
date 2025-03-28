﻿page 6151205 "NPR NpCs Coll. Store Orders"
{
    Caption = 'Collect in Store Orders';
    CardPageId = "NPR NpCs Coll. StoreOrder Card";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NPR NpCs Document";
    SourceTableView = where(Type = const("Collect in Store"),
                            "Document Type" = filter(Order | "Posted Invoice"));
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        RunCard();
                    end;
                }
                field("Reference No."; Rec."Reference No.")
                {

                    ToolTip = 'Specifies the value of the Reference No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        RunCard();
                    end;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {

                    ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        RunCard();
                    end;
                }
                field("Inserted at"; Rec."Inserted at")
                {

                    ToolTip = 'Specifies the value of the Inserted at field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        RunCard();
                    end;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("From Document Type"; Rec."From Document Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the From Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("From Document No."; Rec."From Document No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the From Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("From Store Code"; Rec."From Store Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the From Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Status"; Rec."Processing Status")
                {

                    ToolTip = 'Specifies the value of the Processing Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing updated at"; Rec."Processing updated at")
                {

                    ToolTip = 'Specifies the value of the Processing updated at field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing updated by"; Rec."Processing updated by")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Processing updated by field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer E-mail"; Rec."Customer E-mail")
                {

                    ToolTip = 'Specifies the value of the Customer E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Phone No."; Rec."Customer Phone No.")
                {

                    ToolTip = 'Specifies the value of the Customer Phone No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Send Notification from Store"; Rec."Send Notification from Store")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                    ApplicationArea = NPRRetail;
                }
                field("Notify Customer via E-mail"; Rec."Notify Customer via E-mail")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Notify Customer via E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Notify Customer via Sms"; Rec."Notify Customer via Sms")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Notify Customer via Sms field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Stock"; Rec."Store Stock")
                {

                    ToolTip = 'Specifies the value of the Store Stock field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Status"; Rec."Delivery Status")
                {

                    ToolTip = 'Specifies the value of the Delivery Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery updated at"; Rec."Delivery updated at")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Delivery updated at field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery updated by"; Rec."Delivery updated by")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Delivery updated by field';
                    ApplicationArea = NPRRetail;
                }
                field("Prepaid Amount"; Rec."Prepaid Amount")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Prepaid Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Prepayment Account No."; Rec."Prepayment Account No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Prepayment Account No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Document Type"; Rec."Delivery Document Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Delivery Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Document No."; Rec."Delivery Document No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Delivery Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Archive on Delivery"; Rec."Archive on Delivery")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Archive on Delivery field';
                    ApplicationArea = NPRRetail;
                }
                field(LastLogMessage; Rec.GetLastLogMessage())
                {

                    Caption = 'Last Log Message';
                    ToolTip = 'Specifies the value of the Last Log Message field';
                    ApplicationArea = NPRRetail;
                }
                field(LastLogErrorMessage; Rec.GetLastLogErrorMessage())
                {

                    Caption = 'Last Log Error Message';
                    Style = Attention;
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the Last Log Error Message field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
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

                    ToolTip = 'Print the selected Orders';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsDocument: Record "NPR NpCs Document";
                        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(NpCsDocument);
                        if NpCsDocument.FindSet() then
                            repeat
                                if NpCsDocument."Processing Print Template" <> '' then
                                    NpCsCollectMgt.PrintOrder(NpCsDocument);
                            until NpCsDocument.Next() = 0;
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
                    Visible = (Rec."Delivery Status" = Rec."Delivery Status"::Delivered) and (((Rec."Bill via" = Rec."Bill via"::POS) and (Rec."Delivery Print Template (POS)" <> '')) or ((Rec."Bill via" = Rec."Bill via"::"Sales Document") and (Rec."Delivery Print Template (S.)" <> '')));

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
                    Visible = ((Rec."Processing Status" = 0) or (Rec."Processing Status" = 1)) and (Rec."Delivery Status" = 0);

                    ToolTip = 'Confirms the selected  Orders';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsDocument: Record "NPR NpCs Document";
                        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                        ConfirmSingleQst: Label 'Confirm Order %1?';
                        ConfirmMultipleQst: Label 'Confirm selected Orders?';

                    begin
                        CurrPage.SetSelectionFilter(NpCsDocument);
                        if NpCsDocument.Count = 1 then begin
                            if not Confirm(ConfirmSingleQst, true, NpCsDocument."Document No.") then
                                exit;
                        end else
                            if not Confirm(ConfirmMultipleQst, true) then
                                exit;
                        if NpCsDocument.FindSet() then
                            repeat
                                if ((NpCsDocument."Processing Status" = 0) or (NpCsDocument."Processing Status" = 1)) and (NpCsDocument."Delivery Status" = 0) then
                                    NpCsCollectMgt.ConfirmProcessing(NpCsDocument);
                            until NpCsDocument.Next() = 0;
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
                    Visible = ((Rec."Processing Status" = 0) or (Rec."Processing Status" = 1)) and (Rec."Delivery Status" = 0) and (Rec."Store Stock");

                    ToolTip = 'Executes the Reject Order action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                        ConfirmQst: Label 'Reject Order %1?';
                    begin
                        if not Confirm(ConfirmQst, true, Rec."Document No.") then
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
                        NpCsDocument: Record "NPR NpCs Document";
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(NpCsDocument);
                        if NpCsDocument.FindSet(true) then
                            repeat
                                if NpCsDocument."Send Notification from Store" then begin
                                    NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
                                    Commit();
                                end;
                            until NpCsDocument.Next() = 0;
                    end;
                }
                action(Archive)
                {
                    Caption = 'Archive';
                    Image = Archive;

                    ToolTip = 'Executes the Archive action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsArchCollectMgt: Codeunit "NPR NpCs Arch. Collect Mgt.";
                        SuccessMsg: Label 'Collect %1 %2 has been archived.';
                        FailedMsg: Label 'Collect %1 %2 could not be archived:\\%3';
                        ConfirmQst: Label 'Collect %1 %2 has not been delivered.\\Archive anyway?';
                    begin
                        if (Rec."Processing Status" in [Rec."Processing Status"::" ", Rec."Processing Status"::Pending, Rec."Processing Status"::Confirmed]) and
                          (Rec."Delivery Status" in [Rec."Delivery Status"::" ", Rec."Delivery Status"::Ready])
                        then begin
                            if not Confirm(ConfirmQst, false, Rec."Document Type", Rec."Document No.") then
                                exit;
                        end;
                        if NpCsArchCollectMgt.ArchiveCollectDocument(Rec, true) then
                            Message(SuccessMsg, Rec."Document Type", Rec."Reference No.")
                        else
                            Message(FailedMsg, Rec."Document Type", Rec."Reference No.", GetLastErrorText);

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

                    ToolTip = 'Executes the Invoke Callback action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsDocument: Record "NPR NpCs Document";
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(NpCsDocument);
                        if NpCsDocument.FindSet() then
                            repeat
                                NpCsWorkflowMgt.RunCallback(NpCsDocument);
                            until NpCsDocument.Next() = 0;
                    end;
                }
            }
        }
        area(Navigation)
        {
            action(Document)
            {
                Caption = 'Document';
                Image = Document;
                ShortcutKey = 'Shift+F7';

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
                ShortcutKey = 'Ctrl+F7';

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

    trigger OnAfterGetCurrRecord()
    begin
        HasCallback := Rec."Callback Data".HasValue();
    end;

    var
        HasCallback: Boolean;

    local procedure RunCard()
    begin
        Page.Run(Page::"NPR NpCs Coll. StoreOrder Card", Rec);
    end;
}

