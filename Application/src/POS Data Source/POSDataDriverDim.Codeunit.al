codeunit 6150732 "NPR POS Data Driver: Dim."
{
    Access = Internal;

    local procedure ThisExtension(): Text
    begin

        exit('DIMENSION');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: List of [Text])
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin

        if POSDataMgt.POSDataSource_BuiltInSale() <> DataSourceName then
            exit;

        Extensions.Add(ThisExtension());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin

        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale()) or (ExtensionName <> ThisExtension()) then
            exit;

        Handled := true;

        GeneralLedgerSetup.Get();

        AddDimensionCode(DataSource, GeneralLedgerSetup."Shortcut Dimension 1 Code", '1');
        AddDimensionCode(DataSource, GeneralLedgerSetup."Shortcut Dimension 2 Code", '2');
        AddDimensionCode(DataSource, GeneralLedgerSetup."Shortcut Dimension 3 Code", '3');
        AddDimensionCode(DataSource, GeneralLedgerSetup."Shortcut Dimension 4 Code", '4');
        AddDimensionCode(DataSource, GeneralLedgerSetup."Shortcut Dimension 5 Code", '5');
        AddDimensionCode(DataSource, GeneralLedgerSetup."Shortcut Dimension 6 Code", '6');
        AddDimensionCode(DataSource, GeneralLedgerSetup."Shortcut Dimension 7 Code", '7');
        AddDimensionCode(DataSource, GeneralLedgerSetup."Shortcut Dimension 8 Code", '8');
    end;

    local procedure AddDimensionCode(var DataSource: Codeunit "NPR Data Source"; DimensionCode: Code[20]; ShortcutNumber: Code[10])
    var
        DataType: Enum "NPR Data Type";
        Dimension: Record Dimension;
    begin
        if (DimensionCode = '') then
            exit;
        if not Dimension.Get(DimensionCode) then
            exit;
        DataSource.AddColumn(DimensionCode, Dimension.Description, DataType::String, false);
        DataSource.AddColumn(ShortcutNumber, Dimension.Description, DataType::String, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        DimensionManagement: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        SalePOS: Record "NPR POS Sale";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin

        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale()) or (ExtensionName <> ThisExtension()) then
            exit;

        Handled := true;

        POSSession.GetSetup(Setup);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        GeneralLedgerSetup.Get();

        DimensionManagement.GetDimensionSet(TempDimSetEntry, SalePOS."Dimension Set ID");

        AddDimesionValue(DataRow, TempDimSetEntry, GeneralLedgerSetup."Shortcut Dimension 1 Code", '1');
        AddDimesionValue(DataRow, TempDimSetEntry, GeneralLedgerSetup."Shortcut Dimension 2 Code", '2');
        AddDimesionValue(DataRow, TempDimSetEntry, GeneralLedgerSetup."Shortcut Dimension 3 Code", '3');
        AddDimesionValue(DataRow, TempDimSetEntry, GeneralLedgerSetup."Shortcut Dimension 4 Code", '4');
        AddDimesionValue(DataRow, TempDimSetEntry, GeneralLedgerSetup."Shortcut Dimension 5 Code", '5');
        AddDimesionValue(DataRow, TempDimSetEntry, GeneralLedgerSetup."Shortcut Dimension 6 Code", '6');
        AddDimesionValue(DataRow, TempDimSetEntry, GeneralLedgerSetup."Shortcut Dimension 7 Code", '7');
        AddDimesionValue(DataRow, TempDimSetEntry, GeneralLedgerSetup."Shortcut Dimension 8 Code", '8');
    end;

    local procedure AddDimesionValue(var DataRow: Codeunit "NPR Data Row"; var DimSetEntryTmp: Record "Dimension Set Entry" temporary; DimensionCode: Code[20]; ShortcutNumber: Code[10])
    begin
        //-NPR5.52 [368673]
        if DimensionCode = '' then
            exit;
        //+NPR5.52 [368673]

        DimSetEntryTmp.SetFilter("Dimension Code", '=%1', DimensionCode);
        if (not DimSetEntryTmp.FindFirst()) then
            //EXIT;  //NPR5.52 [368673]-revoked
            DimSetEntryTmp.Init();  //NPR5.52 [368673]

        DataRow.Add(DimensionCode, DimSetEntryTmp."Dimension Value Code");
        DataRow.Add(ShortcutNumber, DimSetEntryTmp."Dimension Value Code");
    end;
}

