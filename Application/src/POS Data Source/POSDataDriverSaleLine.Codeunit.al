codeunit 6150712 "NPR POS Data Driver: Sale Line"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSource', '', false, false)]
    local procedure GetDataSource(Name: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        POSUnit: Record "NPR POS Unit";
        SaleLine: Record "NPR POS Sale Line";
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        if Name <> DataMgt.POSDataSource_BuiltInSaleLine() then
            exit;

        DataSource.Constructor();
        DataSource.SetId(Name);
        DataSource.SetTableNo(Database::"NPR POS Sale Line");
        Setup.GetPOSUnit(POSUnit);

        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("No."), false, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Line Type"), false, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo(Description), true, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Description 2"), false, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Variant Code"), false, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo(Quantity), true, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Unit of Measure Code"), false, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Unit Price"), true, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Unit Cost"), false, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Discount %"), Setup.ShowDiscountFieldsInSaleView(), true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Discount Amount"), Setup.ShowDiscountFieldsInSaleView(), true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo(Amount), not POSUnit.ShowPricesIncludingVAT(), true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Amount Including VAT"), POSUnit.ShowPricesIncludingVAT(), true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Location Code"), false, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Bin Code"), false, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Serial No."), false, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Lot No."), false, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo(Indentation), false, false);

        DataSource.Totals().Add('AmountExclVAT');
        DataSource.Totals().Add('VATAmount');
        DataSource.Totals().Add('TotalAmount');
        DataSource.Totals().Add('ItemCount');

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnRefreshDataSet', '', false, false)]
    local procedure RefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; var CurrDataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        DataMgt: Codeunit "NPR POS Data Management";
        SaleLine: Codeunit "NPR POS Sale Line";
    begin
        if DataSource.Id() <> DataMgt.POSDataSource_BuiltInSaleLine() then
            exit;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.ToDataset(CurrDataSet, DataSource, POSSession, FrontEnd);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnAfterReadDataSourceRow', '', false, false)]
    local procedure OnAfterReadDataSourceRow(POSSession: Codeunit "NPR POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: Codeunit "NPR Data Row")
    var
        SaleLine: Record "NPR POS Sale Line";
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        if DataSource <> DataMgt.POSDataSource_BuiltInSaleLine() then
            exit;

        RecRef.SetTable(SaleLine);
        if SaleLine.Quantity < 0 then
            DataRow.SetNegative(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnSetPosition', '', false, false)]
    local procedure SetPosition(DataSource: Text; Position: Text; POSSession: Codeunit "NPR POS Session"; var Handled: Boolean)
    var
        DataMgt: Codeunit "NPR POS Data Management";
        SaleLine: Codeunit "NPR POS Sale Line";
    begin
        if DataSource <> DataMgt.POSDataSource_BuiltInSaleLine() then
            exit;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.SetPosition(Position);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Data Source Discovery", 'OnDiscoverDataSource', '', false, false)]
    local procedure OnDiscoverDataSource(var Rec: Record "NPR POS Data Source Discovery")
    var
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        Rec.RegisterDataSource(DataMgt.POSDataSource_BuiltInSaleLine(), '(Built-in data source)');
    end;
}
