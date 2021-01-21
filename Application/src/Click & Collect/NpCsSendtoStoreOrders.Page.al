page 6151204 "NPR NpCs Send to Store Orders"
{
    Caption = 'Send to Store Orders';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR NpCs Document";
    SourceTableView = SORTING("Entry No.")
                      WHERE(Type = CONST("Send to Store"),
                            "Document Type" = CONST(Order));
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                }
                field("Workflow Code"; "Workflow Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Code field';
                }
                field("Next Workflow Step"; "Next Workflow Step")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Next Workflow Step field';
                }
                field("From Store Code"; "From Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Store Code field';
                }
                field("To Document Type"; "To Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Document Type field';
                }
                field("To Document No."; "To Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Document No. field';
                }
                field("To Store Code"; "To Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Store Code field';
                }
                field("Store Stock"; "Store Stock")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Stock field';
                }
                field("Prepaid Amount"; "Prepaid Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prepaid Amount field';
                }
                field("Prepayment Account No."; "Prepayment Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prepayment Account No. field';
                }
                field(LastLogMessage; GetLastLogMessage())
                {
                    ApplicationArea = All;
                    Caption = 'Last Log Message';
                    ToolTip = 'Specifies the value of the Last Log Message field';
                }
                field(LastLogErrorMessage; GetLastLogErrorMessage())
                {
                    ApplicationArea = All;
                    Caption = 'Last Log Error Message';
                    Style = Attention;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the value of the Last Log Error Message field';
                }
                field("Processing Status"; "Processing Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Status field';
                }
                field("Processing updated at"; "Processing updated at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing updated at field';
                }
                field("Processing updated by"; "Processing updated by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing updated by field';
                }
                field("Customer E-mail"; "Customer E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer E-mail field';
                }
                field("Customer Phone No."; "Customer Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Phone No. field';
                }
                field("Send Notification from Store"; "Send Notification from Store")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                }
                field("Notify Customer via E-mail"; "Notify Customer via E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notify Customer via E-mail field';
                }
                field("Notify Customer via Sms"; "Notify Customer via Sms")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notify Customer via Sms field';
                }
                field("Delivery Status"; "Delivery Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Status field';
                }
                field("Delivery updated at"; "Delivery updated at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery updated at field';
                }
                field("Delivery updated by"; "Delivery updated by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery updated by field';
                }
                field("Send Order Module"; "Send Order Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Order Module field';
                }
                field("Order Status Module"; "Order Status Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Status Module field';
                }
                field("Post Processing Module"; "Post Processing Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Processing Module field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(New)
            {
                Caption = 'New';
                Image = NewDocument;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+Insert';
                ToolTip = 'Create new Collect in Store Order';
                ApplicationArea = All;

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
                ApplicationArea = All;
                ToolTip = 'Executes the Run Next Workflow Step action';

                trigger OnAction()
                var
                    NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                    NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                begin
                    NpCsWorkflowMgt.ScheduleRunWorkflow(Rec);

                    NpCsCollectMgt.RunLog(Rec, true);
                end;
            }
            group("Send Order")
            {
                Caption = 'Send Order';
                action("Send Order to Store")
                {
                    Caption = 'Send Order to Store';
                    Image = Approve;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send Order to Store action';

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        NpCsWorkflowMgt.RunWorkflowSendOrder(Rec);
                    end;
                }
                action("Send Notification to Store")
                {
                    Caption = 'Send Notification to Store';
                    Image = SendTo;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send Notification to Store action';

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        NpCsWorkflowMgt.SendNotificationToStore(Rec);
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Update Order Status action';

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        NpCsWorkflowMgt.RunWorkflowOrderStatus(Rec);
                    end;
                }
                action("Send Notification to Customer")
                {
                    Caption = 'Send Notification to Customer';
                    Image = SendTo;
                    Visible = NOT "Send Notification from Store";
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
            group("Post Processing")
            {
                Caption = 'Post Processing';
                action("Perform Post Processing")
                {
                    Caption = 'Perform Post Processing';
                    Image = Intercompany;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Perform Post Processing action';

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        NpCsWorkflowMgt.RunWorkflowPostProcessing(Rec);
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
                        if ("Processing Status" in ["Processing Status"::" ", "Processing Status"::Pending, "Processing Status"::Confirmed]) and
                          ("Delivery Status" in ["Delivery Status"::" ", "Delivery Status"::Ready])
                        then begin
                            if not Confirm(Text002, false, "Document Type", "Document No.") then
                                exit;
                        end;
                        if NpCsArchCollectMgt.ArchiveCollectDocument(Rec) then
                            Message(Text003, "Document Type", "Reference No.")
                        else
                            Message(Text004, "Document Type", "Reference No.", GetLastErrorText);

                        CurrPage.Update(false);
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

    var
        Text002: Label 'Collect %1 %2 has not been delivered.\\Archive anyway?';
        Text003: Label 'Collect %1 %2 has been archived.';
        Text004: Label 'Collect %1 %2 could not be archived:\\%3';
}

