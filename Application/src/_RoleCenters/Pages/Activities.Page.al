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
                field(ImportUnprocessed; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Import Pending"))))
                {
                    Caption = 'Import Unprocessed';
                    ToolTip = 'Specifies the value of the Import Unprocessed field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR Nc Import List");
                        CurrPage.Update(false);
                    end;
                }
                field(TaskList; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Task List"))))
                {
                    Caption = 'Task List';
                    ToolTip = 'Specifies the value of the Task List field';
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
                    ToolTip = 'Specifies the value of the Failed Webshop Payments field';
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
                    ToolTip = 'Specifies the amount of failed import entries';
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
                    ToolTip = 'Specifies the value of the Daily Sales Orders field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownSalesOrderList(Rec.FieldNo("Daily Sales Orders"));
                    end;
                }
                field(TotalSalesOrders; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Sales Orders"))))
                {
                    Caption = 'Sales Orders';
                    ToolTip = 'Specifies the value of the Sales Orders field';
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
                    ToolTip = 'Specifies the value of the Shipped Sales Orders field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownSalesOrderList(Rec.FieldNo("Shipped Sales Orders"));
                    end;
                }
                field(SalesReturnOrders; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Sales Return Orders"))))
                {
                    Caption = 'Sales Return Orders';
                    ToolTip = 'Specifies the value of the Sales Return Orders field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"Sales Return Order List");
                        CurrPage.Update(false);
                    end;
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
        end;
        Page.RunModal(Page::"Sales Order List", SalesHeader);
        CurrPage.Update(false);
    end;

    var
        BackgroundTaskResults: Dictionary of [Text, Text];
        BackgroundTaskId: Integer;


}
