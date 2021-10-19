codeunit 6150732 "NPR POS Data Driver: Dim."
{
    // NPR5.44/TSA /20180709 CASE 321303 Initial Version
    // NPR5.48/MMV /20181105 CASE 334588 Fixed mismatch in event subscriber signature
    // NPR5.52/ALPO/20190912 CASE 368673 Add dimension values to the data source even if there is no value at the moment


    trigger OnRun()
    begin
    end;

    local procedure ThisDataSource(): Text
    begin

        exit('BUILTIN_SALE');
    end;

    local procedure ThisExtension(): Text
    begin

        exit('DIMENSION');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: List of [Text])
    begin

        if ThisDataSource() <> DataSourceName then
            exit;

        Extensions.Add(ThisExtension());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin

        if (DataSourceName <> ThisDataSource()) or (ExtensionName <> ThisExtension()) then
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

        Dimension.Get(DimensionCode);
        DataSource.AddColumn(DimensionCode, Dimension.Description, DataType::String, false);
        DataSource.AddColumn(ShortcutNumber, Dimension.Description, DataType::String, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        DimensionManagement: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        SalePOS: Record "NPR POS Sale";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin

        if (DataSourceName <> ThisDataSource()) or (ExtensionName <> ThisExtension()) then
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

