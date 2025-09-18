#if not BC17
report 6014569 "NPR Spfy Upd. Cust.Sync Status"
{
    Extensible = false;
    Caption = 'Update Shopify Customer Sync Status';
    UsageCategory = Tasks;
    ApplicationArea = NPRShopify;
    ProcessingOnly = true;

    dataset
    {
        dataitem(ShopifyStoreDataItem; "NPR Spfy Store")
        {
            RequestFilterFields = Code;
            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(CreateShopifyCustomers; CreateAtShopify)
                    {
                        Caption = 'Create Customers in Shopify';
                        ToolTip = 'Specifies if you want to create customers in Shopify.';
                        ApplicationArea = NPRShopify;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        ExcelFileStream: InStream;
        SheetName: Text[250];
    begin
        SelectExcelWorksheet(SheetName, ExcelFileStream);
        TempExcelBuffer.OpenBookStream(ExcelFileStream, SheetName);
        TempExcelBuffer.ReadSheet();
        AnalyzeData();
    end;

    local procedure AnalyzeData()
    var
        Customer: Record Customer;
        ShopifyStore: Record "NPR Spfy Store";
#if not (BC18 or BC19)
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorContextElement0: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageMgt: Codeunit "Error Message Management";
#endif
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyUpdateCustIntState: Codeunit "NPR Spfy Update Cust.Int.State";
        Window: Dialog;
        CounterReadRows: Integer;
        CounterProcessed: Integer;
        RecNo: Integer;
        TotalRecNo: Integer;
        CellValueAsText: Text;
#if not (BC18 or BC19)
        ErrorMessage: Text;
#endif
        Success: Boolean;
#if not (BC18 or BC19)
        BatchProcessingTxt: Label 'Resyncing customers from Excel worksheet.';
        DefaultErrorMsg: Label 'An error occurred. No further information has been provided.';
#endif
        DialogTxt01Lbl: Label 'Updating Customer Integration Status...\\';
        DialogTxt02Lbl: Label '@1@@@@@@@@@@@@@@@@@@@@@@@@@';
        DoneLbl: Label 'Update process completed successfully.';
#if not (BC18 or BC19)
        CustomerNotFoundErr: Label 'Row No. %1: customer %2 not found.', Comment = '%1 - Excel row number, %2 - customer number';
#endif        
        NothingToImportErr: Label 'There is nothing to do.';
#if not (BC18 or BC19)
        ProcessingMsg: Label 'Processing customer %1.', Comment = '%1 - customer number';
#endif
    begin
        TempExcelBuffer.SetRange("Column No.", 1);
        if TempExcelBuffer.IsEmpty() then
            Error(NothingToImportErr);

        ShopifyStore.CopyFilters(ShopifyStoreDataItem);
        ShopifyStore.FindSet();
        repeat
            SpfyIntegrationMgt.CheckIsEnabled("NPR Spfy Integration Area"::" ", ShopifyStore.Code);
        until ShopifyStore.Next() = 0;
        Commit();

        Window.Open(
            DialogTxt01Lbl +
            DialogTxt02Lbl);
        Window.Update(1, 0);
        TotalRecNo := TempExcelBuffer.Count();
        RecNo := 0;

        Clear(SpfyUpdateCustIntState);
        SpfyUpdateCustIntState.SetProcessingOptions(ShopifyStore, false, CreateAtShopify);
#if not (BC18 or BC19)
        if ErrorMessageMgt.Activate(ErrorMessageHandler) then
            ErrorMessageMgt.PushContext(ErrorContextElement0, Database::Customer, 0, BatchProcessingTxt);
#endif

        repeat
            RecNo += 1;
            if GetCellValueAsText(RecNo, 1, MaxStrLen(Customer."No."), CellValueAsText) then begin
                CounterReadRows += 1;
                if Customer.Get(CellValueAsText) then begin
#if not (BC18 or BC19)
                    ErrorMessageMgt.PushContext(ErrorContextElement, Customer.RecordId(), 0, StrSubstNo(ProcessingMsg, Customer."No."));
#endif

                    Success := SpfyUpdateCustIntState.Run(Customer);
                    if Success then
                        CounterProcessed += 1
#if (BC18 or BC19)
                end;
#else
                    else begin
                        ErrorMessage := GetLastErrorText();
                        if ErrorMessage = '' then
                            ErrorMessage := DefaultErrorMsg;
                        ErrorMessageMgt.LogError(Customer, ErrorMessage, '');
                        ErrorMessageMgt.PopContext(ErrorContextElement);
                    end;
                    ClearLastError();
                end else
                    ErrorMessageMgt.LogError(CellValueAsText, StrSubstNo(CustomerNotFoundErr, RecNo, CellValueAsText), '');
#endif
            end;
            Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
        until RecNo = TotalRecNo;
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        Window.Close();

#if (BC18 or BC19)
        if CounterProcessed = CounterReadRows then
#else
        if CounterProcessed <> CounterReadRows then begin
            ErrorMessageHandler.InformAboutErrors(Enum::"Error Handling Options"::"Show Error");
            ErrorMessageMgt.PopContext(ErrorContextElement0);
        end else
#endif
            Message(DoneLbl);
    end;

    local procedure SelectExcelWorksheet(var SheetName: Text[250]; var ExcelFileStream: InStream)
    var
        FileManagement: Codeunit "File Management";
        ServerFileName: Text;
        ExcelFileExtensionTok: Label '.xlsx', Locked = true;
        ImportFromExcelLbl: Label 'Select Excel File';
    begin
        if not UploadIntoStream(ImportFromExcelLbl, '', FileManagement.GetToFilterText('', ExcelFileExtensionTok), ServerFileName, ExcelFileStream) or (ServerFileName = '') then
            Error('');
        if SheetName = '' then
            SheetName := TempExcelBuffer.SelectSheetsNameStream(ExcelFileStream);
        if SheetName = '' then
            Error('');
    end;

    local procedure GetCellValueAsText(RowNo: Integer; ColumnNo: Integer; MaxLength: Integer; var CellValueAsText: Text): Boolean
    begin
        if not TempExcelBuffer.Get(RowNo, ColumnNo) then
            exit(false);
        CellValueAsText := DelChr(TempExcelBuffer."Cell Value as Text", '<>');
        if MaxLength > 1 then
            CellValueAsText := CopyStr(CellValueAsText, 1, MaxLength);
        exit(CellValueAsText <> '');
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        CreateAtShopify: Boolean;
}
#endif