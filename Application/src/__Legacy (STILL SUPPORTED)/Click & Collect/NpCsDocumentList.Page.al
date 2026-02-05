page 6151200 "NPR NpCs Document List"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    ApplicationArea = NPRRetail;
    Caption = 'Collect Document List';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR NpCs Document";
    UsageCategory = Administration;
    ContextSensitiveHelpPage = 'docs/retail/click_and_collect/intro/';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies unique identifier for this document.';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies reference number associated with this document for tracking purposes.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the type of this document.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies name of the customer who initiated this transaction.';
                }
                field("Workflow Code"; Rec."Workflow Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies code of the workflow associated with this document.';
                }
                field("Next Workflow Step"; Rec."Next Workflow Step")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the next step in the workflow process for this document.';
                }
                field("From Document No."; Rec."From Document No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies document number from which this document originated.';
                }
                field("From Store Code"; Rec."From Store Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies code of the store from which this document originates.';
                }
                field("To Document Type"; Rec."To Document Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies type of the document to which this document will be sent.';
                }
                field("To Document No."; Rec."To Document No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies document number to which this document is being sent.';
                }
                field("To Store Code"; Rec."To Store Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies code of the store to which this document is being sent.';
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies current processing status of this document.';
                }
                field("Processing updated at"; Rec."Processing updated at")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies timestamp when the processing status was last updated.';
                }
                field("Processing updated by"; Rec."Processing updated by")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies user who last updated the processing status.';
                }
                field("Customer E-mail"; Rec."Customer E-mail")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies email address of the customer associated with this document.';
                }
                field("Customer Phone No."; Rec."Customer Phone No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies phone number of the customer associated with this document.';
                }
                field("Send Notification from Store"; Rec."Send Notification from Store")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether a notification is being sent from the store.';
                }
                field("Notify Customer via E-mail"; Rec."Notify Customer via E-mail")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the customer should be notified via email.';
                }
                field("Notify Customer via Sms"; Rec."Notify Customer via Sms")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the customer should be notified via SMS.';
                }
                field("Delivery Status"; Rec."Delivery Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies current delivery status of this document.';
                }
                field("Delivery updated at"; Rec."Delivery updated at")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies timestamp when the delivery status was last updated.';
                }
                field("Delivery updated by"; Rec."Delivery updated by")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies user who last updated the delivery status.';
                }
                field("Store Stock"; Rec."Store Stock")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies stock status of the store associated with this document.';
                }
                field("Bill via"; Rec."Bill via")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies method used for billing this document.';
                }
                field("Delivery Print Template (POS)"; Rec."Delivery Print Template (POS)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies print template used for Point of Sale (POS) delivery.';
                }
                field("Delivery Print Template (S.)"; Rec."Delivery Print Template (S.)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies print template used for Sales Document delivery.';
                }
                field("Prepaid Amount"; Rec."Prepaid Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies amount prepaid for this document';
                }
                field("Prepayment Account No."; Rec."Prepayment Account No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies account number associated with the prepayment for this document.';
                }
                field("Delivery Document Type"; Rec."Delivery Document Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies type of the delivery document associated with this order.';
                }
                field("Delivery Document No."; Rec."Delivery Document No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies document number of the associated delivery document.';
                }
                field("Archive on Delivery"; Rec."Archive on Delivery")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether this document should be archived upon delivery.';
                }
                field("Send Order Module"; Rec."Send Order Module")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies module responsible for sending the order associated with this document.';
                }
                field("Order Status Module"; Rec."Order Status Module")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies module responsible for updating the order status.';
                }
                field("Post Processing Module"; Rec."Post Processing Module")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies module responsible for post-processing tasks related to this document.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies unique entry number for this record.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Run Next Workflow Step")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Run Next Workflow Step';
                Image = Start;
                ToolTip = 'Advance the document to the next workflow step.';

                trigger OnAction()
                var
                    NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                begin
                    NpCsWorkflowMgt.ScheduleRunWorkflow(Rec);
                end;
            }
            group("Send Order")
            {
                Caption = 'Send Order';
                action("Send Order to Store")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Send Order to Store';
                    Image = Approve;
                    ToolTip = 'Initiate the process of sending the order to the designated store.';

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        NpCsWorkflowMgt.RunWorkflowSendOrder(Rec);
                    end;
                }
                action("Send Notification to Store")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Send Notification to Store';
                    Image = SendTo;
                    ToolTip = 'Send a notification to the store regarding this order.';

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        Rec.TestField(Type, Rec.Type::"Send to Store");
                        NpCsWorkflowMgt.SendNotificationToStore(Rec);
                    end;
                }
            }
            group("Order Status")
            {
                Caption = 'Order Status';
                action("Update Order Status")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Update Order Status';
                    Image = ChangeStatus;
                    ToolTip = 'Manually update the status of this order.';

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        NpCsWorkflowMgt.RunWorkflowOrderStatus(Rec);
                    end;
                }
            }
            group("Post Processing")
            {
                Caption = 'Post Processing';
                action("Perform Post Processing")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Perform Post Processing';
                    Image = Intercompany;
                    ToolTip = 'Execute post-processing tasks for this document.';

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        NpCsWorkflowMgt.RunWorkflowPostProcessing(Rec);
                    end;
                }
            }
        }
        area(navigation)
        {
            action(Document)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Document';
                Image = Document;
                ShortCutKey = 'Shift+F7';
                ToolTip = 'Open the detailed document view for this record.';

                trigger OnAction()
                var
                    NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                begin
                    NpCsCollectMgt.RunDocumentCard(Rec);
                end;
            }
            action("Log Entries")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Log Entries';
                Image = Log;
                ShortCutKey = 'Ctrl+F7';
                ToolTip = 'View log entries and history associated with this document.';

                trigger OnAction()
                var
                    NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
                begin
                    NpCsCollectMgt.RunLog(Rec, false);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
    begin
        NpCsCollectMgt.NewCollectOrder();
    end;
}