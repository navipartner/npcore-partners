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
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

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
                field("Failed tasks"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Failed Webshop Payments"))))
                {
                    Caption = 'Failed Capturing of Payments';
                    ToolTip = 'Specifies the number of the failed capturing of payments.';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        PaymentLine: Record "NPR Magento Payment Line";
                    begin
                        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
                        PaymentLine.SetFilter("Payment Gateway Code", '<>%1', '');
                        PaymentLine.SetRange("Date Captured", 0D);

                        Page.RunModal(Page::"NPR Magento Payment Line List", PaymentLine);
                        CurrPage.Update(false);
                    end;
                }

                field("Failed imports in the import list"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Failed imports"))))
                {
                    Caption = 'Failed Imports in the Import List';
                    ToolTip = 'Specifies the number of failed import entries from the Import List.';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

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
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
                field("Failed Inc Ecom Sales Orders"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Failed Inc Ecom Sales Orders"))))
                {
                    Caption = 'Failed Incoming Ecommerce Sales Orders';

                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    ToolTip = 'Specifies the value of the Failed Incoming Ecommerce Sales Orders field.';
                    ApplicationArea = NPRRetail;
                    trigger OnDrillDown()
                    var
                        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
                    begin
                        IncEcomSalesDocUtils.OpenFailedSalesOrders();
                    end;
                }
#endif

            }
            cuegroup(Control6150624)
            {
                Caption = 'Sales';
                ShowCaption = true;
                field(TodaysSalesOrders; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Daily Sales Orders"))))
                {
                    Caption = 'Daily Sales Orders';
                    ToolTip = 'Specifies the number of the daily sales orders that have been registered on today''s date.';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownSalesOrderList(Rec.FieldNo("Daily Sales Orders"));
                    end;
                }
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
                field(TodaysIncEcomSalesOrders; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Daily Inc Ecom Sales Orders"))))
                {
                    Caption = 'Daily Incoming Ecommerce Sales Orders';
                    ToolTip = 'Specifies the number of the daily incoming ecomerce sales orders that have been registered on today''s date.';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    ApplicationArea = NPRRetail;
                    trigger OnDrillDown()
                    var
                        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
                    begin
                        IncEcomSalesDocUtils.OpenSalesOrders(Format(Today));
                    end;
                }
#endif
                field(TotalSalesOrders; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Sales Orders"))))
                {
                    Caption = 'Sales Orders';
                    ToolTip = 'Specifies the number of the sales orders that have been registered.';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

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
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

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
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"Sales Return Order List");
                        CurrPage.Update(false);
                    end;
                }
            }
            cuegroup(Purchases)
            {
                Caption = 'Purchases';
                field(PurchaseOrderList; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Purchase Order List"))))
                {
                    Caption = 'Purchase Orders';
                    ShowCaption = true;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Displays the number of the Purchase Orders made. If you click you can drilldown to the list of Purchase Orders.';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    var
                        PurchaseOrderListPage: Page "Purchase Order List";
                    begin
                        PurchaseOrderListPage.RunModal();
                    end;
                }
            }
            cuegroup("Incoming Documents")
            {
                Caption = 'Incoming Documents';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '2023-06-28';
                ObsoleteReason = 'Moved to page 6151260 "NPR POS Entry Cue"';

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

    local procedure GetFieldValueFromBackgroundTaskResultSet(FieldNo: Text) Result: Decimal
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
