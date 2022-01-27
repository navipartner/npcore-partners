page 6151200 "NPR NpCs Document List"
{
    Extensible = False;
    Caption = 'Collect Document List';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpCs Document";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Reference No."; Rec."Reference No.")
                {

                    ToolTip = 'Specifies the value of the Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
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
                field("From Document No."; Rec."From Document No.")
                {

                    ToolTip = 'Specifies the value of the From Document No. field';
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
                field("Store Stock"; Rec."Store Stock")
                {

                    ToolTip = 'Specifies the value of the Store Stock field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill via"; Rec."Bill via")
                {

                    ToolTip = 'Specifies the value of the Bill via field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Print Template (POS)"; Rec."Delivery Print Template (POS)")
                {

                    ToolTip = 'Specifies the value of the Delivery Print Template (POS) field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Print Template (S.)"; Rec."Delivery Print Template (S.)")
                {

                    ToolTip = 'Specifies the value of the Delivery Template (Sales Document) field';
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
                field("Delivery Document Type"; Rec."Delivery Document Type")
                {

                    ToolTip = 'Specifies the value of the Delivery Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Document No."; Rec."Delivery Document No.")
                {

                    ToolTip = 'Specifies the value of the Delivery Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Archive on Delivery"; Rec."Archive on Delivery")
                {

                    ToolTip = 'Specifies the value of the Archive on Delivery field';
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
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Run Next Workflow Step action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
                begin
                    NpCsWorkflowMgt.ScheduleRunWorkflow(Rec);
                    //NpCsCollectMgt.RunLog(Rec, true);
                end;
            }
            group("Send Order")
            {
                Caption = 'Send Order';
                action("Send Order to Store")
                {
                    Caption = 'Send Order to Store';
                    Image = Approve;

                    ToolTip = 'Executes the Send Order to Store action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Send Notification to Store action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Update Order Status action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Perform Post Processing action';
                    ApplicationArea = NPRRetail;

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
                ShortCutKey = 'Ctrl+F7';

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
}

