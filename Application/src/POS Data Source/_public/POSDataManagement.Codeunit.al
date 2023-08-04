codeunit 6150710 "NPR POS Data Management"
{
    var
        _POSDataMgmtInternal: Codeunit "NPR POS Data Mgmt. Internal";

    procedure AddFieldToDataSource(DataSource: Codeunit "NPR Data Source"; "Record": Variant; FieldNo: Integer; Visible: Boolean)
    begin
        AddFieldToDataSource(DataSource, "Record", FieldNo, Visible, false);
    end;

    procedure AddFieldToDataSource(DataSource: Codeunit "NPR Data Source"; "Record": Variant; FieldNo: Integer; Visible: Boolean; Editable: Boolean)
    begin
        _POSDataMgmtInternal.AddFieldToDataSource(DataSource, Record, FieldNo, Visible);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetDataSource(Name: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetDataSource(Name: Text; DataSource: Codeunit "NPR Data Source"; Setup: Codeunit "NPR POS Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: List of [Text])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; var CurrDataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterRefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; CurrDataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    /// <summary>
    /// Event called after a a data source row has been read and converted to DataRow instance. It allows individual
    /// data source to modify the content of the DataRow (for example, setting negative property, etc.)
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterReadDataSourceRow(POSSession: Codeunit "NPR POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: Codeunit "NPR Data Row")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnReadDataSourceVariables(POSSession: Codeunit "NPR POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: Codeunit "NPR Data Row"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterReadDataSourceVariables(POSSession: Codeunit "NPR POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: Codeunit "NPR Data Row")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetPosition(DataSource: Text; Position: Text; POSSession: Codeunit "NPR POS Session"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnIsDataSourceModified(POSSession: Codeunit "NPR POS Session"; DataSource: Text; var Modified: Boolean)
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    [Obsolete('We are slowly moving the concept of a view out of backend, into frontend with data pulled by frontend instead of pushed out of backend depending on a flag backend remembers between requests.', 'NPR23.0')]
    local procedure OnSetupDataSourcesForView(View: Codeunit "NPR POS View"; Setup: Codeunit "NPR POS Setup")
    begin
    end;

    procedure POSDataSource_BuiltInSale(): Text[50]
    begin
        exit('BUILTIN_SALE');
    end;

    procedure POSDataSource_BuiltInSaleLine(): Text[50]
    begin
        exit('BUILTIN_SALELINE');
    end;

    procedure POSDataSource_BuiltInPaymentLine(): Text[50]
    begin
        exit('BUILTIN_PAYMENTLINE');
    end;
}
