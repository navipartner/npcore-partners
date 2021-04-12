page 6151200 "NPR NpCs Document List"
{
    Caption = 'Collect Document List';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpCs Document";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                }
                field("Workflow Code"; Rec."Workflow Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Code field';
                }
                field("Next Workflow Step"; Rec."Next Workflow Step")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Next Workflow Step field';
                }
                field("From Document No."; Rec."From Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Document No. field';
                }
                field("From Store Code"; Rec."From Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Store Code field';
                }
                field("To Document Type"; Rec."To Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Document Type field';
                }
                field("To Document No."; Rec."To Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Document No. field';
                }
                field("To Store Code"; Rec."To Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Store Code field';
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
                    ToolTip = 'Specifies the value of the Processing updated by field';
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
                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                }
                field("Notify Customer via E-mail"; Rec."Notify Customer via E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notify Customer via E-mail field';
                }
                field("Notify Customer via Sms"; Rec."Notify Customer via Sms")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notify Customer via Sms field';
                }
                field("Delivery Status"; Rec."Delivery Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Status field';
                }
                field("Delivery updated at"; Rec."Delivery updated at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery updated at field';
                }
                field("Delivery updated by"; Rec."Delivery updated by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery updated by field';
                }
                field("Store Stock"; Rec."Store Stock")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Stock field';
                }
                field("Bill via"; Rec."Bill via")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill via field';
                }
                field("Delivery Print Template (POS)"; Rec."Delivery Print Template (POS)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Print Template (POS) field';
                }
                field("Delivery Print Template (S.)"; Rec."Delivery Print Template (S.)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Template (Sales Document) field';
                }
                field("Prepaid Amount"; Rec."Prepaid Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prepaid Amount field';
                }
                field("Prepayment Account No."; Rec."Prepayment Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prepayment Account No. field';
                }
                field("Delivery Document Type"; Rec."Delivery Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Document Type field';
                }
                field("Delivery Document No."; Rec."Delivery Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Document No. field';
                }
                field("Archive on Delivery"; Rec."Archive on Delivery")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archive on Delivery field';
                }
                field("Send Order Module"; Rec."Send Order Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Order Module field';
                }
                field("Order Status Module"; Rec."Order Status Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Status Module field';
                }
                field("Post Processing Module"; Rec."Post Processing Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Processing Module field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
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
}

