page 6151204 "NPR NpCs Send to Store Orders"
{
    Extensible = false;
    Caption = 'Send to Store Orders';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR NpCs Document";
    SourceTableView = sorting("Entry No.")
                      where(Type = const("Send to Store"),
                            "Document Type" = const(Order));
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Reference No."; Rec."Reference No.")
                {

                    ToolTip = 'Specifies the value of the Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {

                    ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Workflow Code"; Rec."Workflow Code")
                {

                    ToolTip = 'Specifies the value of the Workflow Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Next Workflow Step"; Rec."Next Workflow Step")
                {

                    ToolTip = 'Specifies the value of the Next Workflow Step field';
                    ApplicationArea = NPRRetail;
                }
                field("From Store Code"; Rec."From Store Code")
                {

                    ToolTip = 'Specifies the value of the From Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("To Document Type"; Rec."To Document Type")
                {

                    ToolTip = 'Specifies the value of the To Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("To Document No."; Rec."To Document No.")
                {

                    ToolTip = 'Specifies the value of the To Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("To Store Code"; Rec."To Store Code")
                {

                    ToolTip = 'Specifies the value of the To Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Stock"; Rec."Store Stock")
                {

                    ToolTip = 'Specifies the value of the Store Stock field';
                    ApplicationArea = NPRRetail;
                }
                field("Prepaid Amount"; Rec."Prepaid Amount")
                {

                    ToolTip = 'Specifies the value of the Prepaid Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Prepayment Account No."; Rec."Prepayment Account No.")
                {

                    ToolTip = 'Specifies the value of the Prepayment Account No. field';
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

                    ToolTip = 'Specifies the value of the Processing updated by field';
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

                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                    ApplicationArea = NPRRetail;
                }
                field("Notify Customer via E-mail"; Rec."Notify Customer via E-mail")
                {

                    ToolTip = 'Specifies the value of the Notify Customer via E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Notify Customer via Sms"; Rec."Notify Customer via Sms")
                {

                    ToolTip = 'Specifies the value of the Notify Customer via Sms field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Status"; Rec."Delivery Status")
                {

                    ToolTip = 'Specifies the value of the Delivery Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery updated at"; Rec."Delivery updated at")
                {

                    ToolTip = 'Specifies the value of the Delivery updated at field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery updated by"; Rec."Delivery updated by")
                {

                    ToolTip = 'Specifies the value of the Delivery updated by field';
                    ApplicationArea = NPRRetail;
                }
                field("Send Order Module"; Rec."Send Order Module")
                {

                    ToolTip = 'Specifies the value of the Send Order Module field';
                    ApplicationArea = NPRRetail;
                }
                field("Order Status Module"; Rec."Order Status Module")
                {

                    ToolTip = 'Specifies the value of the Order Status Module field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Processing Module"; Rec."Post Processing Module")
                {

                    ToolTip = 'Specifies the value of the Post Processing Module field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(New)
            {
                Caption = 'New';
                Image = NewDocument;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                ShortcutKey = 'Ctrl+Insert';
                ToolTip = 'Create new Collect in Store Order';
                ApplicationArea = NPRRetail;


                trigger OnAction()
                var
                    NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                begin
                    NpCsCollectMgt.NewCollectOrder();
                end;
            }
            action("Run Next Workflow Step")
            {
                Caption = 'Run Next Workflow Step';
                Image = Start;

                ToolTip = 'Executes the Run Next Workflow Step action for selected orders';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpCsDocument: Record "NPR NpCs Document";
                    NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                begin
                    CurrPage.SetSelectionFilter(NpCsDocument);
                    if NpCsDocument.FindSet() then
                        repeat
                            NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
                        until NpCsDocument.Next() = 0;
                end;
            }
            group("Send Order")
            {
                Caption = 'Send Order';
                action("Send Order to Store")
                {
                    Caption = 'Send Order to Store';
                    Image = Approve;

                    ToolTip = 'Executes the Send Order to Store action for selected orders';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsDocument: Record "NPR NpCs Document";
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(NpCsDocument);
                        if NpCsDocument.FindSet() then
                            repeat
                                NpCsWorkflowMgt.RunWorkflowSendOrder(NpCsDocument);
                            until NpCsDocument.Next() = 0;
                    end;
                }
                action("Send Notification to Store")
                {
                    Caption = 'Send Notification to Store';
                    Image = SendTo;

                    ToolTip = 'Executes the Send Notification to Store action for selected orders';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsDocument: Record "NPR NpCs Document";
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(NpCsDocument);
                        if NpCsDocument.FindSet() then
                            repeat
                                NpCsWorkflowMgt.SendNotificationToStore(NpCsDocument);
                            until NpCsDocument.Next() = 0;
                    end;
                }
            }
            group("Order Status")
            {
                Caption = 'Order Status';
                action("Update Order Status")
                {
                    Caption = 'Update Order Status';
                    Image = ChangeStatus;

                    ToolTip = 'Executes the Update Order Status action for selected orders';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsDocument: Record "NPR NpCs Document";
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(NpCsDocument);
                        if NpCsDocument.FindSet() then
                            repeat
                                NpCsWorkflowMgt.RunWorkflowOrderStatus(NpCsDocument);
                            until NpCsDocument.Next() = 0;
                    end;
                }
                action("Send Notification to Customer")
                {
                    Caption = 'Send Notification to Customer';
                    Image = SendTo;
                    Visible = not Rec."Send Notification from Store";

                    ToolTip = 'Executes the Send Notification to Customer action for selected orders';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsDocument: Record "NPR NpCs Document";
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(NpCsDocument);
                        if NpCsDocument.FindSet() then
                            repeat
                                if NpCsDocument."Send Notification from Store" then
                                    NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
                            until NpCsDocument.Next() = 0;
                    end;
                }
            }
            group("Post Processing")
            {
                Caption = 'Post Processing';
                action("Perform Post Processing")
                {
                    Caption = 'Perform Post Processing';
                    Image = Intercompany;

                    ToolTip = 'Executes the Perform Post Processing action for selected orders';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpCsDocument: Record "NPR NpCs Document";
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(NpCsDocument);
                        if NpCsDocument.FindSet() then
                            repeat
                                NpCsWorkflowMgt.RunWorkflowPostProcessing(NpCsDocument);
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
                        ConfirmQst: Label 'Collect %1 %2 has not been delivered.\\Archive anyway?';
                        SuccessMsg: Label 'Collect %1 %2 has been archived.';
                        FailedMsg: Label 'Collect %1 %2 could not be archived:\\%3';
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

    var
}

