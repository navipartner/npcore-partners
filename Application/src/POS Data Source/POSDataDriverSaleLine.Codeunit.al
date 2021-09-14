codeunit 6150712 "NPR POS Data Driver: Sale Line"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSource', '', false, false)]
    local procedure GetDataSource(Name: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        POSViewProfile: Record "NPR POS View Profile";
        SaleLine: Record "NPR POS Sale Line";
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        if Name <> GetSourceNameText() then
            exit;

        DataSource.Constructor();
        DataSource.SetId(Name);
        DataSource.SetTableNo(Database::"NPR POS Sale Line");
        Setup.GetPOSViewProfile(POSViewProfile);

        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("No."), false);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo(Type), false);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo(Description), true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Description 2"), false);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Variant Code"), false);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo(Quantity), true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Unit of Measure Code"), false);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Unit Price"), true);
        if Setup.ShowDiscountFieldsInSaleView() then begin
            DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Discount %"), true);
            DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Discount Amount"), true);
        end;
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo(Amount), POSViewProfile."Tax Type" = POSViewProfile."Tax Type"::"Sales Tax");
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Amount Including VAT"), POSViewProfile."Tax Type" = POSViewProfile."Tax Type"::VAT);

        DataSource.Totals().Add('AmountExclVAT');
        DataSource.Totals().Add('VATAmount');
        DataSource.Totals().Add('TotalAmount');
        DataSource.Totals().Add('ItemCount');

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnRefreshDataSet', '', false, false)]
    local procedure RefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; var CurrDataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SaleLine: Codeunit "NPR POS Sale Line";
    begin
        if DataSource.Id() <> GetSourceNameText() then
            exit;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.ToDataset(CurrDataSet, DataSource, POSSession, FrontEnd);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnAfterReadDataSourceRow', '', false, false)]
    local procedure OnAfterReadDataSourceRow(POSSession: Codeunit "NPR POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: Codeunit "NPR Data Row")
    var
        SaleLine: Record "NPR POS Sale Line";
    begin
        if DataSource <> GetSourceNameText() then
            exit;

        RecRef.SetTable(SaleLine);
        if SaleLine.Quantity < 0 then
            DataRow.SetNegative(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnSetPosition', '', false, false)]
    local procedure SetPosition(DataSource: Text; Position: Text; POSSession: Codeunit "NPR POS Session"; var Handled: Boolean)
    var
        SaleLine: Codeunit "NPR POS Sale Line";
    begin
        if DataSource <> GetSourceNameText() then
            exit;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.SetPosition(Position);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, 6150708, 'OnDiscoverDataSource', '', false, false)]
    local procedure OnDiscoverDataSource(var Rec: Record "NPR POS Data Source Discovery")
    begin
        Rec.RegisterDataSource(GetSourceNameText(), '(Built-in data source)');
    end;

    local procedure GetSourceNameText(): Text[50]
    begin
        exit('BUILTIN_SALELINE');
    end;
}
