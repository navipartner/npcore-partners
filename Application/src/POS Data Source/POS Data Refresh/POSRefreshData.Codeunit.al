codeunit 6150791 "NPR POS Refresh Data"
{
    Access = Internal;

    var
        _POSRefreshPaymentLine: Codeunit "NPR POS Refresh Payment Line";
        _POSRefreshSaleLine: Codeunit "NPR POS Refresh Sale Line";
        _POSRefreshSale: Codeunit "NPR POS Refresh Sale";
        _RefreshAll: Boolean;

    procedure StartDataCollection(Context: JsonObject)
    var
        JToken: JsonToken;
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        POSSession.GetSaleContext(POSSale, POSSaleLine, POSPaymentLine);

        BindSubscription(_POSRefreshSale);
        if Context.SelectToken('data.positions.BUILTIN_SALE', JToken) then begin
            POSSale.SetPosition(JToken.AsValue().AsText());
        end;

        BindSubscription(_POSRefreshSaleLine);
        if Context.SelectToken('data.positions.BUILTIN_SALELINE', JToken) then begin
            POSSaleLine.SetPosition(JToken.AsValue().AsText());
        end;

        BindSubscription(_POSRefreshPaymentLine);
        if Context.SelectToken('data.positions.BUILTIN_PAYMENTLINE', JToken) then begin
            POSPaymentLine.SetPosition(JToken.AsValue().AsText());
        end
    end;

    procedure Refresh()
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        DataSets: JsonObject;
        POSDataManagement: Codeunit "NPR POS Data Management";
    begin
        if (_RefreshAll) then begin
            //Only set on action error, view switch and by rare actions like resume sale which re-uses old POS lines without modifying/inserting them.
            DataSets.Add(POSDataManagement.POSDataSource_BuiltInSale(), _POSRefreshSale.GetFullDataInCurrentSale());
            DataSets.Add(POSDataManagement.POSDataSource_BuiltInSaleLine(), _POSRefreshSaleLine.GetFullDataInCurrentSale());
            DataSets.Add(POSDataManagement.POSDataSource_BuiltInPaymentLine(), _POSRefreshPaymentLine.GetFullDataInCurrentSale());
        end else begin
            DataSets.Add(POSDataManagement.POSDataSource_BuiltInSale(), _POSRefreshSale.GetDeltaData());
            DataSets.Add(POSDataManagement.POSDataSource_BuiltInSaleLine(), _POSRefreshSaleLine.GetDeltaData());
            DataSets.Add(POSDataManagement.POSDataSource_BuiltInPaymentLine(), _POSRefreshPaymentLine.GetDeltaData());
        end;

        POSSession.GetFrontEnd(POSFrontEndManagement);
        POSFrontEndManagement.RefreshData(DataSets);
    end;

    procedure SetFullRefresh()
    begin
        _RefreshAll := true;
    end;
}