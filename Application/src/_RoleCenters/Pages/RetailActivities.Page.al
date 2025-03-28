﻿page 6059812 "NPR Retail Activities"
{
    Extensible = False;
    Caption = 'Retail Activities';
    PageType = CardPart;
    SourceTable = "NPR Retail Sales Cue";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            cuegroup(Control6150623)
            {
                ShowCaption = false;
                field("Sales Orders"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Sales Orders"))))
                {
                    Caption = 'Sales Orders';
                    Image = "Document";
                    ToolTip = 'Specifies the number of the created sales orders. By clicking you can drill down to the list of the created sales orders.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownSalesOrderList(Rec.FieldNo("Sales Orders"));
                    end;
                }
                field("Daily Sales Orders"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Daily Sales Orders"))))
                {
                    Caption = 'Daily Sales Orders';
                    Image = "Document";
                    ToolTip = 'Specifies the number of the sales orders created today. By clicking you can drilldown to the list of sales orders created today.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownSalesOrderList(Rec.FieldNo("Daily Sales Orders"));
                    end;
                }
                field("Import Pending"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Import Pending"))))
                {
                    Caption = 'Import Pending';
                    Image = "Document";
                    ToolTip = 'Specifies the number of the unprocessed imports. By clicking you can drilldown to the list of unprocessed imports.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"NPR Nc Import List");
                        CurrPage.Update(false);
                    end;
                }
            }
            cuegroup(Videos)
            {
                Caption = 'Videos';
                Visible = ShowProductVideosActivities;
                actions
                {
                    action(ProductVideos)
                    {
                        Caption = 'Product Videos';
                        Image = TileVideo;
                        ToolTip = 'Open a list of videos that showcase some of the product capabilities.';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            Video: Codeunit Video;
                        begin
                            Video.Show("Video Category"::NPR);
                        end;
                    }
                }
            }
            cuegroup(Control6150622)
            {
                ShowCaption = false;
                field("Pending Inc. Documents"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Pending Inc. Documents"))))
                {
                    Caption = 'Pending Inc. Documents';
                    Image = "Document";
                    ToolTip = 'Specifies the number of the tasks processed in error. By clicking you can drilldown to the list of the tasks processed in error.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        IncDocument: Record "Incoming Document";
                    begin
                        IncDocument.Reset();
                        IncDocument.SetFilter("Document Type", '= %1', IncDocument."Document Type"::" ");
                        IncDocument.SetFilter("Document No.", '= %1', '');
                        Page.RunModal(Page::"Incoming Documents", IncDocument);
                        CurrPage.Update(false);
                    end;
                }
                field("Processed Error Tasks"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Processed Error Tasks"))))
                {
                    Caption = 'Processed Error Tasks';
                    Image = "Document";
                    ToolTip = 'Specifies the number of the tasks processed in error. By clicking you can drilldown to the list of the tasks processed in error.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        NcTask: Record "NPR Nc Task";
                    begin
                        NcTask.Reset();
                        NcTask.SetRange("Process Error", true);
                        Page.RunModal(Page::"NPR Nc Task List", NcTask);
                        CurrPage.Update(false);
                    end;
                }
                field("Failed Webshop Payments"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Failed Webshop Payments"))))
                {
                    Caption = 'Failed Webshop Payments';
                    Image = "Document";
                    ToolTip = 'Specifies the number of the failed webshop payments. By clicking you can drilldown to the list of the failed webshop payments.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        MagentoPaymentLine: Record "NPR Magento Payment Line";
                    begin
                        MagentoPaymentLine.Reset();
                        MagentoPaymentLine.SetRange("Document Table No.", 112);
                        MagentoPaymentLine.SetFilter("Payment Gateway Code", '<> %1', '');
                        MagentoPaymentLine.SetFilter("Date Captured", '= %1', 0D);
                        Page.RunModal(Page::"NPR Magento Payment Line List", MagentoPaymentLine);
                        CurrPage.Update(false);
                    end;
                }
            }
            cuegroup(Depreciated)
            {
                Caption = 'Depreciated';
                Visible = false;
                field("Sales Quotes"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Sales Quotes"))))
                {
                    Caption = 'Sales Quotes';
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the number of the created sales quotes. By clicking you can drilldown to the list of the created sales quotes.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"Sales Quotes");
                        CurrPage.Update(false);
                    end;
                }
                field("Sales Return Orders"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Sales Return Orders"))))
                {
                    Caption = 'Sales Return Orders';
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the number of the created sales return orders. By clicking you can drilldown to the list of the created sales return orders.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"Sales Return Order List");
                        CurrPage.Update(false);
                    end;
                }
                field("Magento Orders"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Magento Orders"))))
                {
                    Caption = 'Magento Orders';
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the number of the created magento orders. By clicking you can drilldown to the list of the created magento orders.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        SalesHeader: Record "Sales Header";
                    begin
                        SalesHeader.Reset();
                        SalesHeader.SetFilter("NPR External Order No.", '<> %1', '');
                        SalesHeader.SetFilter("Document Type", '= %1', SalesHeader."Document Type"::Order);
                        Page.RunModal(Page::"Sales Order List", SalesHeader);
                        CurrPage.Update(false);
                    end;
                }
                field("Daily Sales Invoices"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Daily Sales Invoices"))))
                {
                    Caption = 'Daily Sales Invoices';
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the number of the created daily sales invoices. By clicking you can drilldown to the list of the created daily sales invoices.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        SalesInvoiceHeader: Record "Sales Invoice Header";
                    begin
                        SalesInvoiceHeader.Reset();
                        SalesInvoiceHeader.SetRange("Posting Date", WorkDate());
                        Page.RunModal(Page::"Posted Sales Invoices", SalesInvoiceHeader);
                        CurrPage.Update(false);
                    end;
                }
                field("Tasks Unprocessed"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Tasks Unprocessed"))))
                {
                    Caption = 'Tasks Unprocessed';
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the number of the unprocessed tasks. By clicking you can drilldown to the list of the unprocessed tasks';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        NcTask: Record "NPR Nc Task";
                    begin
                        NcTask.Reset();
                        NcTask.SetRange(Processed, false);
                        Page.RunModal(Page::"NPR Nc Task List", NcTask);
                        CurrPage.Update(false);
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

        ShowProductVideosActivities := ClientTypeManagement.GetCurrentClientType() <> CLIENTTYPE::Phone;
        Rec.SetActionableImportEntryTypeFilter();
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
        ClientTypeManagement: Codeunit "Client Type Management";
        ShowProductVideosActivities: Boolean;
        BackgroundTaskId: Integer;
        BackgroundTaskResults: Dictionary of [Text, Text];

}
