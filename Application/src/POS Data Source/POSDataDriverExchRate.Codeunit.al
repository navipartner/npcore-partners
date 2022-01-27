codeunit 6150715 "NPR POS Data Driver: ExchRate"
{
    Access = Internal;
    trigger OnRun()
    begin
    end;

    local procedure ThisDataSource(): Text
    begin

        exit('BUILTIN_SALE');
    end;

    local procedure ThisExtension(): Text
    begin

        exit('FC');
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
        POSPaymentMethod: Record "NPR POS Payment Method";
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> ThisDataSource()) or (ExtensionName <> ThisExtension()) then
            exit;
        POSPaymentMethod.SetFilter("Currency Code", '<>%1', '');
        POSPaymentMethod.SetRange("Block POS Payment", false);
        if (POSPaymentMethod.FindSet()) then begin
            repeat
                DataSource.AddColumn(POSPaymentMethod.Code, POSPaymentMethod.Description, DataType::String, false);
            until (POSPaymentMethod.Next() = 0);
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        Setup: Codeunit "NPR POS Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
    begin

        if (DataSourceName <> ThisDataSource()) or (ExtensionName <> ThisExtension()) then
            exit;
        Handled := true;

        POSSession.GetSetup(Setup);
        POSSession.GetPaymentLine(POSPaymentLine);

        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        POSPaymentMethod.SetFilter("Currency Code", '<>%1', '');
        POSPaymentMethod.SetRange("Block POS Payment", false);
        if POSPaymentMethod.FindSet() then
            repeat
                DataRow.Add(POSPaymentMethod.Code, Format(POSPaymentLine.RoundAmount(POSPaymentMethod, POSPaymentLine.CalculateForeignAmount(POSPaymentMethod, SubTotal))));
            until POSPaymentMethod.Next() = 0;
    end;
}

