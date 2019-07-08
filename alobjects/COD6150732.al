codeunit 6150732 "POS Data Driver - Dimension"
{
    // NPR5.44/TSA /20180709 CASE 321303 Initial Version
    // NPR5.48/MMV /20181105 CASE 334588 Fixed mismatch in event subscriber signature


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

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text;Extensions: DotNet List_Of_T)
    var
        MemberCommunity: Record "MM Member Community";
    begin

        if ThisDataSource <> DataSourceName then
          exit;

        Extensions.Add(ThisExtension);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text;ExtensionName: Text;var DataSource: DotNet DataSource0;var Handled: Boolean;Setup: Codeunit "POS Setup")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin

        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
          exit;

        Handled := true;

        GeneralLedgerSetup.Get ();

        AddDimensionCode (DataSource, GeneralLedgerSetup."Shortcut Dimension 1 Code", '1');
        AddDimensionCode (DataSource, GeneralLedgerSetup."Shortcut Dimension 2 Code", '2');
        AddDimensionCode (DataSource, GeneralLedgerSetup."Shortcut Dimension 3 Code", '3');
        AddDimensionCode (DataSource, GeneralLedgerSetup."Shortcut Dimension 4 Code", '4');
        AddDimensionCode (DataSource, GeneralLedgerSetup."Shortcut Dimension 5 Code", '5');
        AddDimensionCode (DataSource, GeneralLedgerSetup."Shortcut Dimension 6 Code", '6');
        AddDimensionCode (DataSource, GeneralLedgerSetup."Shortcut Dimension 7 Code", '7');
        AddDimensionCode (DataSource, GeneralLedgerSetup."Shortcut Dimension 8 Code", '8');
    end;

    local procedure AddDimensionCode(var DataSource: DotNet DataSource0;DimensionCode: Code[20];ShortcutNumber: Code[10])
    var
        DataType: DotNet DataType;
        Dimension: Record Dimension;
    begin

        if (DimensionCode = '') then
          exit;

        Dimension.Get (DimensionCode);
        DataSource.AddColumn (DimensionCode, Dimension.Description, DataType.String, false);
        DataSource.AddColumn (ShortcutNumber, Dimension.Description, DataType.String, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text;ExtensionName: Text;var RecRef: RecordRef;DataRow: DotNet DataRow0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        DataType: DotNet DataType;
        POSSale: Codeunit "POS Sale";
        Setup: Codeunit "POS Setup";
        DimensionManagement: Codeunit DimensionManagement;
        DimSetEntryTmp: Record "Dimension Set Entry" temporary;
        SalePOS: Record "Sale POS";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin

        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
          exit;

        Handled := true;

        POSSession.GetSetup (Setup);
        POSSession.GetSale (POSSale);
        POSSale.GetCurrentSale (SalePOS);

        GeneralLedgerSetup.Get ();

        DimensionManagement.GetDimensionSet (DimSetEntryTmp, SalePOS."Dimension Set ID");

        AddDimesionValue (DataRow, DimSetEntryTmp, GeneralLedgerSetup."Shortcut Dimension 1 Code", '1');
        AddDimesionValue (DataRow, DimSetEntryTmp, GeneralLedgerSetup."Shortcut Dimension 2 Code", '2');
        AddDimesionValue (DataRow, DimSetEntryTmp, GeneralLedgerSetup."Shortcut Dimension 3 Code", '3');
        AddDimesionValue (DataRow, DimSetEntryTmp, GeneralLedgerSetup."Shortcut Dimension 4 Code", '4');
        AddDimesionValue (DataRow, DimSetEntryTmp, GeneralLedgerSetup."Shortcut Dimension 5 Code", '5');
        AddDimesionValue (DataRow, DimSetEntryTmp, GeneralLedgerSetup."Shortcut Dimension 6 Code", '6');
        AddDimesionValue (DataRow, DimSetEntryTmp, GeneralLedgerSetup."Shortcut Dimension 7 Code", '7');
        AddDimesionValue (DataRow, DimSetEntryTmp, GeneralLedgerSetup."Shortcut Dimension 8 Code", '8');
    end;

    local procedure AddDimesionValue(var DataRow: DotNet DataRow0;var DimSetEntryTmp: Record "Dimension Set Entry" temporary;DimensionCode: Code[20];ShortcutNumber: Code[10])
    begin

        DimSetEntryTmp.SetFilter ("Dimension Code", '=%1', DimensionCode);
        if (not DimSetEntryTmp.FindFirst ()) then
         exit;

        DataRow.Add (DimensionCode, DimSetEntryTmp."Dimension Value Code");
        DataRow.Add (ShortcutNumber, DimSetEntryTmp."Dimension Value Code");
    end;
}

