page 6151255 "NPR Activities"

{
    Extensible = False;
    Caption = 'Sales Activities';
    PageType = CardPart;
    SourceTable = "NPR Retail Sales Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup(Control6150623)
            {
                Caption = 'Integration';
                ShowCaption = true;
                field(TaskList; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Task List"))))
                {
                    Caption = 'Task List';
                    ToolTip = 'Specifies the number of the tasks assigned to the current user.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        NcTaskList: Page "NPR Nc Task List";
                    begin
                        NcTaskList.SetShowProcessed(false);
                        NcTaskList.RunModal();
                        CurrPage.Update(false);
                    end;
                }
            }
            cuegroup(FailedTasks)
            {
                Caption = 'Failed Tasks';
                field("Failed tasks"; Rec."Failed Webshop Payments")
                {
                    Caption = 'Failed Capturing of Payments';
                    ToolTip = 'Specifies the number of the failed capturing of payments.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"NPR Magento Payment Line List");
                        CurrPage.Update(false);
                    end;
                }

                field("Failed imports in the import list"; Rec."Failed imports")
                {
                    Caption = 'Failed Imports in the Import List';
                    ToolTip = 'Specifies the number of failed import entries from the Import List.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        ImportEntry: Record "NPR Nc Import Entry";
                    begin
                        ImportEntry.SetRange("Runtime Error", true);

                        Page.RunModal(Page::"NPR Nc Import List", ImportEntry);
                        CurrPage.Update(false);
                    end;
                }

            }
            cuegroup(Control6150624)
            {
                Caption = 'Sales';
                ShowCaption = true;
                field(TodaysSalesOrders; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Daily Sales Orders"))))
                {
                    Caption = 'Daily Sales Orders';
                    ToolTip = 'Specifies the number of the daily sales orders that have been registered on today''s date.';


                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownSalesOrderList(Rec.FieldNo("Daily Sales Orders"));
                    end;
                }
                field(TotalSalesOrders; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Sales Orders"))))
                {
                    Caption = 'Sales Orders';
                    ToolTip = 'Specifies the number of the sales orders that have been registered.';


                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownSalesOrderList(Rec.FieldNo("Sales Orders"));
                    end;
                }
                field(ShippedSalesOrders; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Shipped Sales Orders"))))
                {
                    Caption = 'Shipped Sales Orders';
                    ShowCaption = true;
                    ToolTip = 'Specifies the number of the sales orders that have been shipped.';


                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownSalesOrderList(Rec.FieldNo("Shipped Sales Orders"));
                    end;
                }
                field(SalesReturnOrders; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Sales Return Orders"))))
                {
                    Caption = 'Sales Return Orders';
                    ShowCaption = true;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Displays the number of the Sales Return Orders. If you click you can drilldown to the list of the Sales Return Orders.';


                    trigger OnDrillDown()
                    begin
                        DrillDownSalesOrderList(Rec.FieldNo("Sales Return Orders"));
                    end;
                }
                field(SalesCreditMemos; Rec."Sales Credit Memos")
                {
                    Caption = 'Sales Credit Memos';
                    ShowCaption = true;
                    ApplicationArea = NPRRetail;
                    DrillDownPageId = "Sales Credit Memos";
                    ToolTip = 'Displays the number of the Sales Credit Memos. If you click you can drilldown to the list of the Sales Credit Memos.';

                }
                field(CollectDocumentList; Rec."Collect Document List")
                {
                    Caption = 'Collect Document List';
                    ShowCaption = true;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the number of the Collect Documents. If you click you can drilldown to the list of Collect Documents.';

                }
            }
            cuegroup("Incoming Documents")
            {
                Caption = 'Incoming Documents';
                field("My Incoming Documents"; Rec."My Incoming Documents")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the number of the incoming documents that are assigned to the current user.';

                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR Activities Backgrd Task");
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        BackgrndTaskMgt.CopyTaskResults(Results, BackgroundTaskResults);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        if (TaskId = BackgroundTaskId) then
            BackgrndTaskMgt.FailedTaskError(CurrPage.Caption(), ErrorCode, ErrorText);
    end;

    local procedure GetFieldValueFromBackgroundTaskResultSet(FieldNo: Text) Result: Integer
    begin
        if not BackgroundTaskResults.ContainsKey(FieldNo) then
            exit(0);
        if not Evaluate(Result, BackgroundTaskResults.Get(FieldNo), 9) then
            Result := 0;
    end;

    local procedure DrillDownSalesOrderList(DrillDownFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        case DrillDownFieldNo of
            Rec.FieldNo("Daily Sales Orders"):
                SalesHeader.SetRange("Posting Date", WorkDate());
            Rec.FieldNo("Shipped Sales Orders"):
                SalesHeader.SetRange("Shipped Not Invoiced", true);
            Rec.FieldNo("Sales Return Orders"):
                SalesHeader.SetRange("Document Type", "Sales Document Type"::"Return Order");
        end;
        Page.RunModal(Page::"Sales Order List", SalesHeader);
        CurrPage.Update(false);
    end;

    var
        BackgroundTaskResults: Dictionary of [Text, Text];
        BackgroundTaskId: Integer;
}
