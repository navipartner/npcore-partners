codeunit 6150853 "POS Extension: Line Formatter"
{
    // NPR5.43/CLVA/20180605 CASE 296709 Created this object to support front-end line formatting.


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscover(DataSourceName: Text;Extensions: DotNet List_Of_T)
    begin
        if DataSourceName = 'BUILTIN_SALELINE' then
          Extensions.Add('LineFormat');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text;ExtensionName: Text;var DataSource: DotNet DataSource0;var Handled: Boolean;Setup: Codeunit "POS Setup")
    var
        DataType: DotNet DataType;
    begin
        if (DataSourceName <> 'BUILTIN_SALELINE') or (ExtensionName <> 'LineFormat') then
          exit;

        Handled := true;

        DataSource.AddColumn('Color','Text color',DataType.String,false);
        DataSource.AddColumn('Weight','Font weight',DataType.String,false);
        DataSource.AddColumn('Style','Font style',DataType.String,false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text;ExtensionName: Text;var RecRef: RecordRef;DataRow: DotNet DataRow0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SaleLine: Record "Sale Line POS";
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

        OnGetLineStyle(Color,Weight,Style,SaleLine,POSSession,FrontEnd);

        DataRow.Fields.Add('Color',Color);
        DataRow.Fields.Add('Weight',Weight);
        DataRow.Fields.Add('Style',Style);
    end;

    [BusinessEvent(false)]
    local procedure OnGetLineStyle(var Color: Text;var Weight: Text;var Style: Text;SaleLinePOS: Record "Sale Line POS";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;
}

