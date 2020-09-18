page 6151200 "NPR NpCs Document List"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Document List';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpCs Document";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Workflow Code"; "Workflow Code")
                {
                    ApplicationArea = All;
                }
                field("Next Workflow Step"; "Next Workflow Step")
                {
                    ApplicationArea = All;
                }
                field("From Document No."; "From Document No.")
                {
                    ApplicationArea = All;
                }
                field("From Store Code"; "From Store Code")
                {
                    ApplicationArea = All;
                }
                field("To Document Type"; "To Document Type")
                {
                    ApplicationArea = All;
                }
                field("To Document No."; "To Document No.")
                {
                    ApplicationArea = All;
                }
                field("To Store Code"; "To Store Code")
                {
                    ApplicationArea = All;
                }
                field("Processing Status"; "Processing Status")
                {
                    ApplicationArea = All;
                }
                field("Processing updated at"; "Processing updated at")
                {
                    ApplicationArea = All;
                }
                field("Processing updated by"; "Processing updated by")
                {
                    ApplicationArea = All;
                }
                field("Customer E-mail"; "Customer E-mail")
                {
                    ApplicationArea = All;
                }
                field("Customer Phone No."; "Customer Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Send Notification from Store"; "Send Notification from Store")
                {
                    ApplicationArea = All;
                }
                field("Notify Customer via E-mail"; "Notify Customer via E-mail")
                {
                    ApplicationArea = All;
                }
                field("Notify Customer via Sms"; "Notify Customer via Sms")
                {
                    ApplicationArea = All;
                }
                field("Delivery Status"; "Delivery Status")
                {
                    ApplicationArea = All;
                }
                field("Delivery updated at"; "Delivery updated at")
                {
                    ApplicationArea = All;
                }
                field("Delivery updated by"; "Delivery updated by")
                {
                    ApplicationArea = All;
                }
                field("Store Stock"; "Store Stock")
                {
                    ApplicationArea = All;
                }
                field("Bill via"; "Bill via")
                {
                    ApplicationArea = All;
                }
                field("Delivery Print Template (POS)"; "Delivery Print Template (POS)")
                {
                    ApplicationArea = All;
                }
                field("Delivery Print Template (S.)"; "Delivery Print Template (S.)")
                {
                    ApplicationArea = All;
                }
                field("Prepaid Amount"; "Prepaid Amount")
                {
                    ApplicationArea = All;
                }
                field("Prepayment Account No."; "Prepayment Account No.")
                {
                    ApplicationArea = All;
                }
                field("Delivery Document Type"; "Delivery Document Type")
                {
                    ApplicationArea = All;
                }
                field("Delivery Document No."; "Delivery Document No.")
                {
                    ApplicationArea = All;
                }
                field("Archive on Delivery"; "Archive on Delivery")
                {
                    ApplicationArea = All;
                }
                field("Send Order Module"; "Send Order Module")
                {
                    ApplicationArea = All;
                }
                field("Order Status Module"; "Order Status Module")
                {
                    ApplicationArea = All;
                }
                field("Post Processing Module"; "Post Processing Module")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
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

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                    begin
                        TestField(Type, Type::"Send to Store");
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
                    Caption = 'Perform Post Processing';
                    Image = Intercompany;
                    ApplicationArea = All;

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
                Caption = 'Document';
                Image = Document;
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
}

