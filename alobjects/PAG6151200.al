page 6151200 "NpCs Document List"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Document List';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NpCs Document";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No.";"Document No.")
                {
                }
                field("Reference No.";"Reference No.")
                {
                }
                field(Type;Type)
                {
                }
                field("Sell-to Customer Name";"Sell-to Customer Name")
                {
                }
                field("Workflow Code";"Workflow Code")
                {
                }
                field("Next Workflow Step";"Next Workflow Step")
                {
                }
                field("From Document No.";"From Document No.")
                {
                }
                field("From Store Code";"From Store Code")
                {
                }
                field("To Document Type";"To Document Type")
                {
                }
                field("To Document No.";"To Document No.")
                {
                }
                field("To Store Code";"To Store Code")
                {
                }
                field("Processing Status";"Processing Status")
                {
                }
                field("Processing updated at";"Processing updated at")
                {
                }
                field("Processing updated by";"Processing updated by")
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
                }
                field("Notify Customer via E-mail";"Notify Customer via E-mail")
                {
                }
                field("Notify Customer via Sms";"Notify Customer via Sms")
                {
                }
                field("Delivery Status";"Delivery Status")
                {
                }
                field("Delivery updated at";"Delivery updated at")
                {
                }
                field("Delivery updated by";"Delivery updated by")
                {
                }
                field("Delivery Only (Non stock)";"Delivery Only (Non stock)")
                {
                }
                field("Bill via";"Bill via")
                {
                }
                field("Delivery Print Template (POS)";"Delivery Print Template (POS)")
                {
                }
                field("Delivery Print Template (S.)";"Delivery Print Template (S.)")
                {
                }
                field("Prepaid Amount";"Prepaid Amount")
                {
                }
                field("Prepayment Account No.";"Prepayment Account No.")
                {
                }
                field("Delivery Document Type";"Delivery Document Type")
                {
                }
                field("Delivery Document No.";"Delivery Document No.")
                {
                }
                field("Archive on Delivery";"Archive on Delivery")
                {
                }
                field("Send Order Module";"Send Order Module")
                {
                }
                field("Order Status Module";"Order Status Module")
                {
                }
                field("Post Processing Module";"Post Processing Module")
                {
                }
                field("Entry No.";"Entry No.")
                {
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

                trigger OnAction()
                var
                    NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
                begin
                    NpCsCollectMgt.NewCollectOrder();
                end;
            }
            action("Run Next Workflow Step")
            {
                Caption = 'Run Next Workflow Step';
                Image = Start;

                trigger OnAction()
                var
                    NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
                    NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
                begin
                    NpCsWorkflowMgt.ScheduleRunWorkflow(Rec);
                    NpCsCollectMgt.RunLog(Rec,true);
                end;
            }
            group("Send Order")
            {
                Caption = 'Send Order';
                action("Send Order to Store")
                {
                    Caption = 'Send Order to Store';
                    Image = Approve;

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
                    begin
                        NpCsWorkflowMgt.RunWorkflowSendOrder(Rec);
                    end;
                }
                action("Send Notification to Store")
                {
                    Caption = 'Send Notification to Store';
                    Image = SendTo;

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
                    begin
                        TestField(Type,Type::"Send to Store");
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

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
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

                    trigger OnAction()
                    var
                        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
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
}

