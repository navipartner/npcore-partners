codeunit 6150791 "NPR POS Refresh Data"
{
    Access = Internal;

    var
        _POSRefreshPaymentLine: Codeunit "NPR POS Refresh Payment Line";
        _POSRefreshSaleLine: Codeunit "NPR POS Refresh Sale Line";
        _POSRefreshSale: Codeunit "NPR POS Refresh Sale";
        _RefreshAll: Boolean;

    procedure StartDataCollection()
    begin
        BindSubscription(_POSRefreshSale);
        BindSubscription(_POSRefreshSaleLine);
        BindSubscription(_POSRefreshPaymentLine);
    end;

    procedure Refresh()
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        DataSets: JsonObject;
        POSDataManagement: Codeunit "NPR POS Data Management";
    begin

        if (not POSSession.IsInitialized()) then
            exit;
            
        // For backwards compatibility we need to always refresh the sale header record, as the POS Sale data drivers depend on a refresh to ship
        // their values to frontend, even when the POS Sale record has not been modified.
        DataSets.Add(POSDataManagement.POSDataSource_BuiltInSale(), _POSRefreshSale.GetFullDataInCurrentSale());

        if (_RefreshAll) then begin
            //Only set on action error, view switch and by rare actions like resume sale which re-uses old POS lines without modifying/inserting them.
            DataSets.Add(POSDataManagement.POSDataSource_BuiltInSaleLine(), _POSRefreshSaleLine.GetFullDataInCurrentSale());
            DataSets.Add(POSDataManagement.POSDataSource_BuiltInPaymentLine(), _POSRefreshPaymentLine.GetFullDataInCurrentSale());
        end else begin
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