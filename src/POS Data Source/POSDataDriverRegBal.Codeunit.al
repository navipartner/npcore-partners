codeunit 6150714 "NPR POS Data Driver: Reg. Bal."
{
    // NPR5.36/TJ  /20170825 CASE 287688 Text constants with nontranslatable text are now functions with hardcoded values
    // NPR5.38/MHA /20180105  CASE 301053 Updated signature of RefreshDataSet() to match new publisher signature


    trigger OnRun()
    begin
    end;

    var
        Caption_CompanyName: Label 'Company Name';

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSource', '', false, false)]
    local procedure GetDataSource(Name: Text; var DataSource: DotNet NPRNetDataSource0; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        Sale: Record "NPR Sale POS";
        DataMgt: Codeunit "NPR POS Data Management";
        DataType: DotNet NPRNetDataType;
    begin
        //-NPR5.36 [287688]
        //IF Name <> SourceName THEN
        if Name <> GetSourceNameText() then
            //+NPR5.36 [287688]
            exit;

        DataSource := DataSource.DataSource();
        DataSource.Id := Name;
        DataSource.TableNo := DATABASE::"NPR Sale POS";
        DataSource.PerSession := true;

        DataSource.AddColumn('RegisterFilter', '', DataType.String, false);
        DataSource.AddColumn('ReceiptFilter', '', DataType.String, false);
        DataSource.AddColumn('PrimoBalance', '', DataType.Decimal, false);
        DataSource.AddColumn('CashMovements', '', DataType.Decimal, false);
        DataSource.AddColumn('MidTotal', '', DataType.Decimal, false);
        DataSource.AddColumn('ManualCards', '', DataType.Decimal, false);
        DataSource.AddColumn('CreditCards', '', DataType.Decimal, false);
        DataSource.AddColumn('OtherCreditCards', '', DataType.Decimal, false);
        DataSource.AddColumn('TerminalTotal', '', DataType.Decimal, false);
        DataSource.AddColumn('GiftVouchers', '', DataType.Decimal, false);
        DataSource.AddColumn('CreditVouchers', '', DataType.Decimal, false);
        DataSource.AddColumn('OutPayments', '', DataType.Decimal, false);
        DataSource.AddColumn('CustomerPayments', '', DataType.Decimal, false);
        DataSource.AddColumn('StaffSales', '', DataType.Decimal, false);
        DataSource.AddColumn('NegativeSalesAmount', '', DataType.Decimal, false);
        DataSource.AddColumn('ForeignCurrency', '', DataType.Decimal, false);
        DataSource.AddColumn('QuantityOfSales', '', DataType.Decimal, false);
        DataSource.AddColumn('QuantityOfCancelledSales', '', DataType.Decimal, false);
        DataSource.AddColumn('QuantityOfNegativeSales', '', DataType.Decimal, false);
        DataSource.AddColumn('NetTurnOver', '', DataType.Decimal, false);
        DataSource.AddColumn('ProfitAmount', '', DataType.Decimal, false);
        DataSource.AddColumn('TurnOver', '', DataType.Decimal, false);
        DataSource.AddColumn('NetCostAmount', '', DataType.Decimal, false);
        DataSource.AddColumn('ProfitCoverage', '', DataType.Decimal, false);
        DataSource.AddColumn('CampaignDiscountAmount', '', DataType.Decimal, false);
        DataSource.AddColumn('CampaignDiscountPct', '', DataType.Decimal, false);
        DataSource.AddColumn('MixedDiscountAmount', '', DataType.Decimal, false);
        DataSource.AddColumn('MixedDiscountPct', '', DataType.Decimal, false);
        DataSource.AddColumn('QuantityDiscountAmount', '', DataType.Decimal, false);
        DataSource.AddColumn('QuantityDiscountPct', '', DataType.Decimal, false);
        DataSource.AddColumn('SalesPersonDiscountAmount', '', DataType.Decimal, false);
        DataSource.AddColumn('SalesPersonDiscountPct', '', DataType.Decimal, false);
        DataSource.AddColumn('BOMListDiscountAmount', '', DataType.Decimal, false);
        DataSource.AddColumn('BOMListDiscountPct', '', DataType.Decimal, false);
        DataSource.AddColumn('CustomerDiscountAmount', '', DataType.Decimal, false);
        DataSource.AddColumn('DiscountAmountPct', '', DataType.Decimal, false);
        DataSource.AddColumn('LineDiscountAmount', '', DataType.Decimal, false);
        DataSource.AddColumn('LineDiscountPct', '', DataType.Decimal, false);
        DataSource.AddColumn('TotalDiscountAmount', '', DataType.Decimal, false);
        DataSource.AddColumn('TotalDiscountPct', '', DataType.Decimal, false);


        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnRefreshDataSet', '', false, false)]
    local procedure RefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: DotNet NPRNetDataSource0; var CurrDataSet: DotNet NPRNetDataSet; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Sale: Codeunit "NPR POS Sale";
        DataRow: DotNet NPRNetDataRow0;
    begin
        //-NPR5.36 [287688]
        //IF DataSource.Id <> SourceName THEN
        if DataSource.Id <> GetSourceNameText() then
            //+NPR5.36 [287688]
            exit;

        //-NPR5.38 [301053]
        //DataSet := DataSet.DataSet(DataSource.Id);
        //DataSet.CurrentPosition := '_';
        //DataRow := DataSet.NewRow(DataSet.CurrentPosition);
        CurrDataSet := CurrDataSet.DataSet(DataSource.Id);
        CurrDataSet.CurrentPosition := '_';
        DataRow := CurrDataSet.NewRow(CurrDataSet.CurrentPosition);
        //+NPR5.38 [301053]

        DataRow.Add('RegisterFilter', 'Register 1');
        DataRow.Add('ReceiptFilter', 'Receipts 1..3');
        DataRow.Add('PrimoBalance', 1);
        DataRow.Add('CashMovements', 2);
        DataRow.Add('MidTotal', 3);
        DataRow.Add('ManualCards', 4);
        DataRow.Add('CreditCards', 5);
        DataRow.Add('OtherCreditCards', 6);
        DataRow.Add('TerminalTotal', 7);
        DataRow.Add('GiftVouchers', 8);
        DataRow.Add('CreditVouchers', 9);
        DataRow.Add('OutPayments', 10);
        DataRow.Add('CustomerPayments', 11);
        DataRow.Add('StaffSales', 12);
        DataRow.Add('NegativeSalesAmount', 13);
        DataRow.Add('ForeignCurrency', 14);
        DataRow.Add('QuantityOfSales', 15);
        DataRow.Add('QuantityOfCancelledSales', 16);
        DataRow.Add('QuantityOfNegativeSales', 17);
        DataRow.Add('NetTurnOver', 18);
        DataRow.Add('ProfitAmount', 19);
        DataRow.Add('TurnOver', 20);
        DataRow.Add('NetCostAmount', 21);
        DataRow.Add('ProfitCoverage', 22);
        DataRow.Add('CampaignDiscountAmount', 23);
        DataRow.Add('CampaignDiscountPct', 24);
        DataRow.Add('MixedDiscountAmount', 25);
        DataRow.Add('MixedDiscountPct', 26);
        DataRow.Add('QuantityDiscountAmount', 27);
        DataRow.Add('QuantityDiscountPct', 28);
        DataRow.Add('SalesPersonDiscountAmount', 29);
        DataRow.Add('SalesPersonDiscountPct', 30);
        DataRow.Add('BOMListDiscountAmount', 31);
        DataRow.Add('BOMListDiscountPct', 32);
        DataRow.Add('CustomerDiscountAmount', 33);
        DataRow.Add('DiscountAmountPct', 34);
        DataRow.Add('LineDiscountAmount', 35);
        DataRow.Add('LineDiscountPct', 36);
        DataRow.Add('TotalDiscountAmount', 37);
        DataRow.Add('TotalDiscountPct', 38);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnSetPosition', '', false, false)]
    local procedure SetPosition(DataSource: Text; Position: Text; POSSession: Codeunit "NPR POS Session"; var Handled: Boolean)
    var
        Sale: Codeunit "NPR POS Sale";
    begin
        //-NPR5.36 [287688]
        //IF DataSource <> SourceName THEN
        if DataSource <> GetSourceNameText() then
            //+NPR5.36 [287688]
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnIsDataSourceModified', '', false, false)]
    local procedure Modified(POSSession: Codeunit "NPR POS Session"; DataSource: Text; var Modified: Boolean)
    var
        Sale: Codeunit "NPR POS Sale";
    begin
        //-NPR5.36 [287688]
        //IF DataSource <> SourceName THEN
        if DataSource <> GetSourceNameText() then
            //+NPR5.36 [287688]
            exit;

        Modified := true;
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
        exit('BUILTIN_REGISTER_BALANCING');
    end;

    local procedure GetLastSaleNoText(): Text
    begin
        exit('LastSaleNo');
    end;

    local procedure GetLastSaleTotalText(): Text
    begin
        exit('LastSaleTotal');
    end;

    local procedure GetLastSalePaidText(): Text
    begin
        exit('LastSalePaid');
    end;

    local procedure GetLastSaleChangeText(): Text
    begin
        exit('LastSaleChange');
    end;

    local procedure GetLastSaleDateText(): Text
    begin
        exit('LastSaleDate');
    end;

    local procedure GetCompanyNameText(): Text
    begin
        exit('CompanyName');
    end;
}

