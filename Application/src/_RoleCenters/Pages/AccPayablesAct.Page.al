page 6151254 "NPR Acc. Payables Act"
{
    Extensible = False;
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Finance Cue";
    UsageCategory = None;
    layout
    {
        area(content)
        {

            cuegroup("Document Approvals")
            {
                Caption = 'Document Approvals';
                Visible = false;
                field("POs Pending Approval"; Rec."POs Pending Approval")
                {

                    DrillDownPageID = "Purchase Order List";
                    ToolTip = 'Specifies the number of purchase orders that are pending approval.';
                    ApplicationArea = NPRRetail;
                }
                field("Approved Purchase Orders"; Rec."Approved Purchase Orders")
                {

                    DrillDownPageID = "Purchase Order List";
                    ToolTip = 'Specifies the number of approved purchase orders.';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                Visible = false;
                field("Pending User Tasks"; UserTaskManagement.GetMyPendingUserTasksCount())
                {

                    Caption = 'Pending User Tasks';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you or to a group that you are a member of.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        UserTaskList: Page "User Task List";
                    begin
                        UserTaskList.SetPageToShowMyPendingUserTasks();
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