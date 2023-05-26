codeunit 6014669 "NPR POS Data Driver: Discount"
{
    Access = Internal;

    local procedure ThisExtension(): Text
    begin
        exit('Discount');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtension(DataSourceName: Text; Extensions: List of [Text])
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSaleLine() then
            exit;

        Extensions.Add(ThisExtension());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSDataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if not ((DataSourceName = POSDataMgt.POSDataSource_BuiltInSaleLine()) and (ExtensionName = ThisExtension())) then
            exit;

        Handled := true;

        DataSource.AddColumn('Type', SaleLinePOS.FieldCaption("Discount Type"), DataType::String, false, true);
        DataSource.AddColumn('Code', SaleLinePOS.FieldCaption("Discount Code"), DataType::String, false, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSDataMgt: Codeunit "NPR POS Data Management";
        Setup: Codeunit "NPR POS Setup";
    begin
        if not ((DataSourceName = POSDataMgt.POSDataSource_BuiltInSaleLine()) and (ExtensionName = ThisExtension())) then
            exit;

        Handled := true;

        POSSession.GetSetup(Setup);

        RecRef.SetTable(SaleLinePOS);

        DataRow.Add('Type', GetDiscountTypeString(SaleLinePOS));
        DataRow.Add('Code', SaleLinePOS."Discount Code");
    end;

    local procedure GetDiscountTypeString(SaleLinePOS: Record "NPR POS Sale Line"): Text
    var
        SalesLinePOSDiscountTypes: Label ' ,Period,Mixed,Multi-Unit,Salesperson,Inventory,N/A,Rounding,Combination,Customer', Comment = 'Shorter version of option values of the field "Discount Type" available on "POS Sale Line" to be able to squeeze them in a column on POS';
    begin
        if SaleLinePOS."Discount Type" > SaleLinePOS."Discount Type"::Customer then
            exit(Format(SaleLinePOS."Discount Type"))
        else
            exit(SelectStr(SaleLinePOS."Discount Type" + 1, SalesLinePOSDiscountTypes));
    end;
}
