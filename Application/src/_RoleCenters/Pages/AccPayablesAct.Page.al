page 6151254 "NPR Acc. Payables Act"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Finance Cue";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            cuegroup(Payments)

            {
                Caption = 'Payments';
                field("NP Purchase Order"; Rec."NPR Purchase Order")
                {
                    Caption = 'Purchase Order';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Purchase List";
                    ToolTip = 'Specifies the number of purchase.';
                }

                field("Purchase Return Orders"; Rec."Purchase Return Orders")
                {
                    ApplicationArea = PurchReturnOrder;
                    DrillDownPageID = "Purchase Return Order List";
                    ToolTip = 'Specifies the number of purchase return orders that are displayed in the Finance Cue on the Role Center. The documents are filtered by today''s date.';
                }

                field("Pending Inc. Documents"; Rec."NPR Pending Inc. Documents")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Incoming Documents";
                    ToolTip = 'Specifies the value of the NPR Pending Inc. Documents field';
                }
            }
            cuegroup("Document Approvals")
            {
                Caption = 'Document Approvals';
                Visible = false;
                field("POs Pending Approval"; Rec."POs Pending Approval")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Purchase Order List";
                    ToolTip = 'Specifies the number of purchase orders that are pending approval.';
                }
                field("Approved Purchase Orders"; Rec."Approved Purchase Orders")
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
                        UserTaskList.Run();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.SetFilter("Due Date Filter", '<=%1', WorkDate());
    end;

    var
        UserTaskManagement: Codeunit "User Task Management";
}

