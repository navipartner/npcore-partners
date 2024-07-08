codeunit 6150713 "NPR POS Data Driver: Pay. Line"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSource', '', false, false)]
    local procedure GetDataSource(Name: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        SaleLine: Record "NPR POS Sale Line";
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        if Name <> DataMgt.POSDataSource_BuiltInPaymentLine() then
            exit;

        DataSource.Constructor();
        DataSource.SetId(Name);
        DataSource.SetTableNo(DATABASE::"NPR POS Sale Line");

        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo(Description), true, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Currency Amount"), true, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Amount Including VAT"), true, true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo(Indentation), false, false);

        DataSource.Totals().Add('SaleAmount');
        DataSource.Totals().Add('PaidAmount');
        DataSource.Totals().Add('ReturnAmount');
        DataSource.Totals().Add('Subtotal');

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnRefreshDataSet', '', false, false)]
    local procedure RefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; var CurrDataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        DataMgt: Codeunit "NPR POS Data Management";
        PaymentLine: Codeunit "NPR POS Payment Line";
    begin
        if DataSource.Id() <> DataMgt.POSDataSource_BuiltInPaymentLine() then
            exit;

        POSSession.GetPaymentLine(PaymentLine);
        PaymentLine.ToDataset(CurrDataSet, DataSource, POSSession, FrontEnd);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnSetPosition', '', false, false)]
    local procedure SetPosition(DataSource: Text; Position: Text; POSSession: Codeunit "NPR POS Session"; var Handled: Boolean)
    var
        DataMgt: Codeunit "NPR POS Data Management";
        PaymentLine: Codeunit "NPR POS Payment Line";
    begin
        if DataSource <> DataMgt.POSDataSource_BuiltInPaymentLine() then
            exit;

        POSSession.GetPaymentLine(PaymentLine);
        PaymentLine.SetPosition(Position);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Data Source Discovery", 'OnDiscoverDataSource', '', false, false)]
    local procedure OnDiscoverDataSource(var Rec: Record "NPR POS Data Source Discovery")
    var
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        Rec.RegisterDataSource(DataMgt.POSDataSource_BuiltInPaymentLine(), '(Built-in data source)');
    end;
}
