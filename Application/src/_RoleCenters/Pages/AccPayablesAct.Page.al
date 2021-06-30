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
                Caption = 'Purchase';
                field("NP Purchase Quote"; Rec."NPR Purchase Quote")
                {
                    Caption = 'Purchase Quote';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Purchase Quotes";
                    ToolTip = 'Specifies the number of purchase quotes.';
                }
                field("NP Purchase Order"; Rec."NPR Purchase Order")
                {
                    Caption = 'Purchase Order';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Purchase Order List";
                    ToolTip = 'Specifies the number of purchase orders.';
                }

                field("Purchase Return Orders"; Rec."Purchase Return Orders")
                {
                    ApplicationArea = PurchReturnOrder;
                    DrillDownPageID = "Purchase Return Order List";
                    ToolTip = 'Specifies the number of purchase return orders that are displayed in the Finance Cue on the Role Center. The documents are filtered by today''s date.';
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
                field("Pending User Tasks"; UserTaskManagement.GetMyPendingUserTasksCount())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending User Tasks';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you or to a group that you are a member of.';

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

