codeunit 6014440 "NPR Item Worksheet"
{
    #region Events
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeExportWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeExportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterImportWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterImportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
    end;

    [BusinessEvent(false)]
    procedure OnAfterRegisterLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeRetJnlLineInsertFromPurchLine(PurchaseLine: Record "Purchase Line"; var RetailJnlLine: Record "NPR Retail Journal Line")
    begin
    end;
    #endregion

    #region ItemWorksheetVariantLine
    procedure UpdateBarcodeVariantLine(var ItemWorkshVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
        ItemWorkshVariantLine.UpdateBarcode();
    end;
    #endregion

    #region ItemWorksheetLine
    procedure UpdateBarcodeLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
        ItemWorksheetLine.UpdateBarcode();
    end;

    procedure GetNewItemWorksheetLineNo(var ItemWorksheetLine: Record "NPR Item Worksheet Line"): Code[20]
    begin
        exit(ItemWorksheetLine.GetNewItemNo());
    end;
    #endregion

    #region CheckLine
    procedure CheckLine(ItemWkshtLine: Record "NPR Item Worksheet Line"; StopOnError: Boolean; CalledFromRegister: Boolean)
    var
        ItemWshtCheckLine: Codeunit "NPR Item Wsht.-Check Line";
    begin
        ItemWshtCheckLine.RunCheck(ItemWkshtLine, StopOnError, CalledFromRegister);
    end;
    #endregion

    #region Register
    procedure ItemWorksheetLineRunCheck(var ItemWorksheetLine: Record "NPR Item Worksheet Line"; StopOnError: Boolean; CalledFromRegister: Boolean)
    var
        ItemWshtCheckLine: Codeunit "NPR Item Wsht.-Check Line";
    begin
        ItemWshtCheckLine.RunCheck(ItemWorksheetLine, StopOnError, CalledFromRegister);
    end;

    procedure ItemWorksheetRunRegisterLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line"): Boolean
    var
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
    begin
        exit(ItemWshtRegisterLine.Run(ItemWorksheetLine));
    end;

    procedure InsertRegisteredWorksheet(var ItemWorksheet: Record "NPR Item Worksheet")
    var
        RegisteredItemWorksheet: Record "NPR Registered Item Works.";
        NextEntryNo: Integer;
    begin
        RegisteredItemWorksheet.LockTable();
        if RegisteredItemWorksheet.FindLast() then
            NextEntryNo := RegisteredItemWorksheet."No.";
        NextEntryNo := NextEntryNo + 1;

        RegisteredItemWorksheet.Init();
        RegisteredItemWorksheet."No." := NextEntryNo;
        RegisteredItemWorksheet."Worksheet Name" := ItemWorksheet.Name;
        RegisteredItemWorksheet.Description := ItemWorksheet.Description;
        RegisteredItemWorksheet."Vendor No." := ItemWorksheet."Vendor No.";
        RegisteredItemWorksheet."Currency Code" := ItemWorksheet."Currency Code";
        RegisteredItemWorksheet."Prices Including VAT" := ItemWorksheet."Prices Including VAT";
        RegisteredItemWorksheet."Print Labels" := ItemWorksheet."Print Labels";
        RegisteredItemWorksheet."No. Series" := ItemWorksheet."No. Series";
        RegisteredItemWorksheet."Item Worksheet Template" := ItemWorksheet."Item Template Name";
        RegisteredItemWorksheet."Registered Date Time" := CurrentDateTime;
        RegisteredItemWorksheet."Registered by User ID" := CopyStr(UserId, 1, MaxStrLen(RegisteredItemWorksheet."Registered by User ID"));
        RegisteredItemWorksheet."Item Group" := ItemWorksheet."Item Group";
        RegisteredItemWorksheet.Insert(true);
    end;

    procedure RegisterLineValidateFields(var Item: Record Item; var ItemWkshLine: Record "NPR Item Worksheet Line"; DoValidateFields: Boolean; DoInsertChangeRecords: Boolean)
    var
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
    begin 
        ItemWshtRegisterLine.ValidateFields(Item, ItemWkshLine, DoValidateFields, DoInsertChangeRecords);
    end;

    procedure MapStandardItemWorksheetLineField(var Item: Record Item; ItemWkshLine: Record "NPR Item Worksheet Line"; SourceFieldNo: Integer): Boolean
    var
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
    begin
        exit(ItemWshtRegisterLine.MapStandardItemWorksheetLineField(Item, ItemWkshLine, SourceFieldNo));
    end;

    procedure RegisterLineUpdateItemAttributes(ItemWkshLine: Record "NPR Item Worksheet Line")
    var
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
    begin
        ItemWshtRegisterLine.UpdateItemAttributes(ItemWkshLine);
    end;

    procedure LastRegisteredWorksheetNo(): Integer
    var
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
    begin
        exit(ItemWshtRegisterLine.LastRegisteredWorksheetNo());
    end;

    procedure CopyToRegisteredWorksheetVariantLine(LineNo: Integer; ItemWkshVariantLine: Record "NPR Item Worksh. Variant Line")
    var
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
    begin
        ItemWshtRegisterLine.CopyToRegisteredWorksheetVariantLine(LineNo, ItemWkshVariantLine);
    end;

    procedure RegisterUpdateAndCopyVarieties(var ItemWorkshLine: Record "NPR Item Worksheet Line"; VarietyNo: Integer; Variety: Code[10]; VarietyTableFrom: Code[40]; VarietyTableTo: Code[40]; CreateCopy: Boolean; CopyValues: Boolean)
    var
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
    begin
        ItemWshtRegisterLine.UpdateAndCopyVarieties(ItemWorkshLine, VarietyNo, Variety, VarietyTableFrom, VarietyTableTo, CreateCopy, CopyValues);
    end;

    procedure CreateRegisteredWorksheetVarietyValues(ItemWorkshLine: Record "NPR Item Worksheet Line")
    var
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
    begin
        ItemWshtRegisterLine.CreateRegisteredWorksheetVarietyValues(ItemWorkshLine);
    end;
    #endregion
}