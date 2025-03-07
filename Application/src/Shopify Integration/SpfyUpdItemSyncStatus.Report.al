#if not BC17
report 6014528 "NPR Spfy Upd. Item Sync Status"
{
    Extensible = false;
    Caption = 'Update Item Sync Status';
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
                    field(CreateShopifyProducts; CreateAtShopify)
                    {
                        Caption = 'Create Products in Shopify';
                        ToolTip = 'Specifies if you want to create products in Shopify.';
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
        Item: Record Item;
        ShopifyStore: Record "NPR Spfy Store";
#if not (BC18 or BC19)
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorContextElement0: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageMgt: Codeunit "Error Message Management";
#endif
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyUpdateItemIntState: Codeunit "NPR Spfy Update Item Int.State";
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
        BatchProcessingTxt: Label 'Resyncing items from Excel worksheet.';
        DefaultErrorMsg: Label 'An error occurred. No further information has been provided.';
#endif
        DialogTxt01Lbl: Label 'Updating Item Integration Status...\\';
        DialogTxt02Lbl: Label '@1@@@@@@@@@@@@@@@@@@@@@@@@@';
        DoneLbl: Label 'Update process completed successfully.';
#if not (BC18 or BC19)
        ItemNotFoundErr: Label 'Row No. %1: Item %2 not found.', Comment = '%1 - Excel row number, %2 - item number';
#endif        
        NothingToImportErr: Label 'There is nothing to do.';
#if not (BC18 or BC19)
        ProcessingMsg: Label 'Processing item %1.', Comment = '%1 - item number';
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

        Clear(SpfyUpdateItemIntState);
        SpfyUpdateItemIntState.SetProcessingOptions(ShopifyStore, false, CreateAtShopify);
#if not (BC18 or BC19)
        if ErrorMessageMgt.Activate(ErrorMessageHandler) then
            ErrorMessageMgt.PushContext(ErrorContextElement0, Database::Item, 0, BatchProcessingTxt);
#endif

        repeat
            RecNo += 1;
            if GetCellValueAsText(RecNo, 1, MaxStrLen(Item."No."), CellValueAsText) then begin
                CounterReadRows += 1;
                if Item.Get(CellValueAsText) then begin
#if not (BC18 or BC19)
                    ErrorMessageMgt.PushContext(ErrorContextElement, Item.RecordId(), 0, StrSubstNo(ProcessingMsg, Item."No."));
#endif

                    Success := SpfyUpdateItemIntState.Run(Item);
                    if Success then
                        CounterProcessed += 1
#if (BC18 or BC19)
                end;
#else
                    else begin
                        ErrorMessage := GetLastErrorText();
                        if ErrorMessage = '' then
                            ErrorMessage := DefaultErrorMsg;
                        ErrorMessageMgt.LogError(Item, ErrorMessage, '');
                        ErrorMessageMgt.PopContext(ErrorContextElement);
                    end;
                    ClearLastError();
                end else
                    ErrorMessageMgt.LogError(CellValueAsText, StrSubstNo(ItemNotFoundErr, RecNo, CellValueAsText), '');
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