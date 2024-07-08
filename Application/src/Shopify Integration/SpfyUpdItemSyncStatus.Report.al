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

    trigger OnPreReport()
    var
        ExcelFileStream: InStream;
        SheetName: Text[250];
        DoneLbl: Label 'Update process completed successfully.';
    begin
        SelectExcelWorksheet(SheetName, ExcelFileStream);
        TempExcelBuffer.OpenBookStream(ExcelFileStream, SheetName);
        TempExcelBuffer.ReadSheet();
        AnalyzeData();
        Message(DoneLbl);
    end;

    local procedure AnalyzeData()
    var
        Item: Record Item;
        ShopifyStore: Record "NPR Spfy Store";
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        CellValueAsText: Text;
        DialogTxt01Lbl: Label 'Updating Item Integration Status...\\';
        DialogTxt02Lbl: Label '@1@@@@@@@@@@@@@@@@@@@@@@@@@';
        NothingToImportErr: Label 'There is nothing to do.';
    begin
        TempExcelBuffer.SetRange("Column No.", 1);
        if TempExcelBuffer.IsEmpty() then
            Error(NothingToImportErr);

        ShopifyStore.CopyFilters(ShopifyStoreDataItem);
        ShopifyStore.FindFirst();

        Window.Open(
            DialogTxt01Lbl +
            DialogTxt02Lbl);
        Window.Update(1, 0);
        TotalRecNo := TempExcelBuffer.Count();
        RecNo := 0;
        repeat
            RecNo += 1;
            if GetCellValueAsText(RecNo, 1, MaxStrLen(Item."No."), CellValueAsText) then
                if Item.Get(CellValueAsText) then begin
                    SendItemAndInventory.MarkItemAlreadyOnShopify(Item, ShopifyStore, false, false);
                    Commit();
                end;
            Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
        until RecNo = TotalRecNo;
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        Window.Close();
    end;

    local procedure SelectExcelWorksheet(var SheetName: Text[250]; var ExcelFileStream: InStream)
    var
        ServerFileName: Text;
        ExcelFileExtensionTok: Label '.xlsx', Locked = true;
        ImportFromExcelLbl: Label 'Select Excel File';
    begin
        if not UploadIntoStream(ImportFromExcelLbl, '', ExcelFileExtensionTok, ServerFileName, ExcelFileStream) or (ServerFileName = '') then
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
}
#endif