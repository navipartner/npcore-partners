#if not BC17
report 6014526 "NPR Spfy Item Calc.Invt Levels"
{
    Extensible = false;
    Caption = 'Recalculate Item Inventory Levels by Batch';
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
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        CellValueAsText: Text;
        DialogTxt01Lbl: Label 'Updating Item Inventory Levels...\\';
        DialogTxt02Lbl: Label '@1@@@@@@@@@@@@@@@@@@@@@@@@@';
        NothingToImportErr: Label 'There is nothing to do.';
        InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
        Item1: Record Item;
    begin
        TempExcelBuffer.SetRange("Column No.", 1);
        if TempExcelBuffer.IsEmpty() then
            Error(NothingToImportErr);

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
                    ClearInventoryLevels(Item, ShopifyStoreDataItem.GetFilter(Code));
                    Item1 := Item;
                    Item1.SetRecFilter();
                    InventoryLevelMgt.InitializeInventoryLevels(ShopifyStoreDataItem.GetFilter(Code), Item1, false);
                    Commit();
                end;
            Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
        until RecNo = TotalRecNo;

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        Window.Close();
    end;

    local procedure ClearInventoryLevels(Item: Record Item; ShopifyStoreFilter: Text)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
    begin
        SpfyStoreItemLink.SetRange(Type, SpfyStoreItemLink.Type::Item);
        SpfyStoreItemLink.SetRange("Item No.", Item."No.");
        SpfyStoreItemLink.SetRange("Variant Code", '');
        if ShopifyStoreFilter <> '' then
            SpfyStoreItemLink.SetFilter("Shopify Store Code", ShopifyStoreFilter);
        if SpfyStoreItemLink.FindSet() then
            repeat
                InventoryLevelMgt.ClearInventoryLevels(SpfyStoreItemLink);
            until SpfyStoreItemLink.Next() = 0;
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