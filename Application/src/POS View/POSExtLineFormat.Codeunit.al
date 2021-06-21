codeunit 6150853 "NPR POS Ext.: Line Format."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscover(DataSourceName: Text; Extensions: List of [Text])
    begin
        if DataSourceName = 'BUILTIN_SALELINE' then
            Extensions.Add('LineFormat');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> 'BUILTIN_SALELINE') or (ExtensionName <> 'LineFormat') then
            exit;

        Handled := true;

        DataSource.AddColumn('Color', 'Text color', DataType::String, false);
        DataSource.AddColumn('Weight', 'Font weight', DataType::String, false);
        DataSource.AddColumn('Style', 'Font style', DataType::String, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SaleLine: Record "NPR POS Sale Line";
        Color: Text;
        Weight: Text;
        Style: Text;
    begin
        if (DataSourceName <> 'BUILTIN_SALELINE') or (ExtensionName <> 'LineFormat') then
            exit;

        Handled := true;

        RecRef.SetTable(SaleLine);

        // Default values: black, normal weight, normal style
        Color := '';
        Weight := '';
        Style := '';

        OnGetLineStyle(Color, Weight, Style, SaleLine, POSSession, FrontEnd);

        DataRow.Fields().Add('Color', Color);
        DataRow.Fields().Add('Weight', Weight);
        DataRow.Fields().Add('Style', Style);
    end;

    [BusinessEvent(false)]
#pragma warning disable AA0150
    local procedure OnGetLineStyle(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "NPR POS Sale Line"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
#pragma warning restore
    begin
    end;
}
