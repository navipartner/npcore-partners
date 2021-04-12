codeunit 6150713 "NPR POS Data Driver: Pay. Line"
{
    // NPR5.36/TJ  /20170825 CASE 287688 Text constants with nontranslatable text are now functions with hardcoded values
    // NPR5.38/MHA /20180105  CASE 301053 Updated signature of RefreshDataSet() to match new publisher signature


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSource', '', false, false)]
    local procedure GetDataSource(Name: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        SaleLine: Record "NPR POS Sale Line";
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        //-NPR5.36 [287688]
        //IF Name <> SourceName THEN
        if Name <> GetSourceNameText() then
            //+NPR5.36 [287688]
            exit;

        DataSource.Constructor();
        DataSource.SetId(Name);
        DataSource.SetTableNo(DATABASE::"NPR POS Sale Line");

        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo(Description), true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Currency Amount"), true);
        DataMgt.AddFieldToDataSource(DataSource, SaleLine, SaleLine.FieldNo("Amount Including VAT"), true);

        DataSource.Totals.Add('SaleAmount');
        DataSource.Totals.Add('PaidAmount');
        DataSource.Totals.Add('ReturnAmount');
        DataSource.Totals.Add('Subtotal');

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnRefreshDataSet', '', false, false)]
    local procedure RefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; var CurrDataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        PaymentLine: Codeunit "NPR POS Payment Line";
    begin
        //-NPR5.36 [287688]
        //IF DataSource.Id <> SourceName THEN
        if DataSource.Id <> GetSourceNameText() then
            //+NPR5.36 [287688]
            exit;

        POSSession.GetPaymentLine(PaymentLine);
        //-NPR5.38 [301053]
        //PaymentLine.ToDataset(DataSet,DataSource,POSSession,FrontEnd);
        PaymentLine.ToDataset(CurrDataSet, DataSource, POSSession, FrontEnd);
        //+NPR5.38 [301053]

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnSetPosition', '', false, false)]
    local procedure SetPosition(DataSource: Text; Position: Text; POSSession: Codeunit "NPR POS Session"; var Handled: Boolean)
    var
        PaymentLine: Codeunit "NPR POS Payment Line";
    begin
        //-NPR5.36 [287688]
        //IF DataSource <> SourceName THEN
        if DataSource <> GetSourceNameText() then
            //+NPR5.36 [287688]
            exit;

        POSSession.GetPaymentLine(PaymentLine);
        PaymentLine.SetPosition(Position);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, 6150708, 'OnDiscoverDataSource', '', false, false)]
    local procedure OnDiscoverDataSource(var Rec: Record "NPR POS Data Source Discovery")
    begin
        //-NPR5.36 [287688]
        //Rec.RegisterDataSource(SourceName,'(Built-in data source)');
        Rec.RegisterDataSource(GetSourceNameText(), '(Built-in data source)');
        //+NPR5.36 [287688]
    end;

    local procedure GetSourceNameText(): Text
    begin
        exit('BUILTIN_PAYMENTLINE');
    end;
}

