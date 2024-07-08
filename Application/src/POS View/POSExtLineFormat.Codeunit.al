codeunit 6150853 "NPR POS Ext.: Line Format."
{
    Access = Internal;
    local procedure CurrExtensionName(): Text
    begin
        exit('LineFormat');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscover(DataSourceName: Text; Extensions: List of [Text])
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if DataSourceName = POSDataMgt.POSDataSource_BuiltInSaleLine() then
            Extensions.Add(CurrExtensionName());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSaleLine()) or (ExtensionName <> CurrExtensionName()) then
            exit;

        Handled := true;

        if Setup.UsesNewPOSFrontEnd() then begin
            DataSource.AddColumn('Highlighted', 'Line highlight', DataType::Boolean, false);
            DataSource.AddColumn('Indented', 'Line indention', DataType::Boolean, false);
        end else begin
            DataSource.AddColumn('Color', 'Text color', DataType::String, false);
            DataSource.AddColumn('Weight', 'Font weight', DataType::String, false);
            DataSource.AddColumn('Style', 'Font style', DataType::String, false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SaleLine: Record "NPR POS Sale Line";
        POSDataMgt: Codeunit "NPR POS Data Management";
        Color: Text;
        Weight: Text;
        Style: Text;
        POSSetup: Codeunit "NPR POS Setup";
        Highlighted: Boolean;
        Indented: Boolean;
    begin
        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSaleLine()) or (ExtensionName <> CurrExtensionName()) then
            exit;

        Handled := true;

        RecRef.SetTable(SaleLine);

        POSSession.GetSetup(POSSetup);

        if POSSetup.UsesNewPOSFrontEnd() then begin
            OnGetLineFormat(Highlighted, Indented, SaleLine);
            OnGetLineFormatting(Highlighted, SaleLine);

            DataRow.Fields().Add('Highlighted', Highlighted);
            DataRow.Fields().Add('Indented', Indented);
        end else begin
            // Default values: black, normal weight, normal style
            Color := '';
            Weight := '';
            Style := '';

            OnGetLineStyle(Color, Weight, Style, SaleLine, POSSession, FrontEnd);

            DataRow.Fields().Add('Color', Color);
            DataRow.Fields().Add('Weight', Weight);
            DataRow.Fields().Add('Style', Style);
        end;
    end;

    [Obsolete('Move to OnGetLineFormatting() subscriber with limited control over styling instead', 'NPR23.0')]
    [BusinessEvent(false)]
#pragma warning disable AA0150
    local procedure OnGetLineStyle(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "NPR POS Sale Line"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
#pragma warning restore
    begin
    end;

    [Obsolete('Move to OnGetLineFormatting() subscriber as the former "Indented" parameter is now part of the core data source as field #6120 of type Integer', 'NPR32.0')]
    [IntegrationEvent(false, false)]
    local procedure OnGetLineFormat(var Highlighted: Boolean; var Indented: Boolean; SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetLineFormatting(var Highlighted: Boolean; SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;
}
