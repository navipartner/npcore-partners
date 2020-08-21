page 6151254 "NP Retail Acc. Payables Act"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Finance Cue";

    layout
    {
        area(content)
        {
            cuegroup(Payments)

            {
                Caption = 'Payments';
                field("NP Purchase Order"; "NP Purchase Order")
                {
                    Caption = 'Purchase Order';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Purchase List";
                    ToolTip = 'Specifies the number of purchase.';
                }

                field("Purchase Return Orders"; "Purchase Return Orders")
                {
                    ApplicationArea = PurchReturnOrder;
                    DrillDownPageID = "Purchase Return Order List";
                    ToolTip = 'Specifies the number of purchase return orders that are displayed in the Finance Cue on the Role Center. The documents are filtered by today''s date.';
                }
                field("Outstanding Vendor Invoices"; "Outstanding Vendor Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of invoices from your vendors that have not been paid yet.';
                }

                field("Pending Inc. Documents"; "Pending Inc. Documents")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Incoming Documents";
                }
                field("Posted Purchase order"; "Posted Purchase order")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Purchase Invoices';
                    DrillDownPageId = "Posted Purchase Invoices";
                }

                actions
                {
                    action("Edit Payment Journal")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Edit Payment Journal';
                        RunObject = Page "Payment Journal";
                        ToolTip = 'Pay your vendors by filling the payment journal automatically according to payments due, and potentially export all payment to your bank for automatic processing.';
                    }
                    action("New Purchase Credit Memo")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New Purchase Credit Memo';
                        RunObject = Page "Purchase Credit Memo";
                        RunPageMode = Create;
                        ToolTip = 'Specifies a new purchase credit memo so you can manage returned items to a vendor.';
                    }
                    action("Edit Purchase Journal")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Edit Purchase Journal';
                        RunObject = Page "Purchase Journal";
                        ToolTip = 'Post purchase invoices in a purchase journal that may already contain journal lines.';
                    }
                }
            }
            cuegroup("Document Approvals")
            {
                Caption = 'Document Approvals';
                Visible = false;
                field("POs Pending Approval"; "POs Pending Approval")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Purchase Order List";
                    ToolTip = 'Specifies the number of purchase orders that are pending approval.';
                }
                field("Approved Purchase Orders"; "Approved Purchase Orders")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Purchase Order List";
                    ToolTip = 'Specifies the number of approved purchase orders.';
                }
            }
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                Visible = false;
                field("UserTaskManagement.GetMyPendingUserTasksCount"; UserTaskManagement.GetMyPendingUserTasksCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending User Tasks';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you or to a group that you are a member of.';

                    trigger OnDrillDown()
                    var
                        UserTaskList: Page "User Task List";
                    begin
                        UserTaskList.SetPageToShowMyPendingUserTasks;
                        UserTaskList.Run;
                    end;
                }
            }


        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;

        SetFilter("Due Date Filter", '<=%1', WorkDate);
        SetFilter("User ID Filter", UserId);
    end;

    var
        UserTaskManagement: Codeunit "User Task Management";
}

