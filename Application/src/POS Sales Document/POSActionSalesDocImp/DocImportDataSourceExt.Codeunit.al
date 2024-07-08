codeunit 6184477 "NPR Doc. Import DataSource Ext" implements "NPR POS DS Exten. Field Setup"
{
    Access = Internal;

    local procedure ThisExtension(): Text[50]
    begin
        exit('SalesDoc');
    end;

    local procedure ExtensionField_OpenOrders(): Text[50]
    begin
        exit('OpenOrdersQty');
    end;

    local procedure DefaultExtensionFieldDescr_OpenOrders(): Text[100]
    var
        ExtFieldDescrLbl: Label 'Number of open sales orders', MaxLength = 100;
    begin
        exit(ExtFieldDescrLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', true, false)]
    local procedure OnDiscoverDataSourceExtension(DataSourceName: Text; Extensions: List of [Text])
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
        DSExtFieldSetupPublic: Codeunit "NPR DS Ext.Field Setup Public";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if POSDataMgt.POSDataSource_BuiltInSale() <> DataSourceName then
            exit;

        DSExtFieldSetupPublic.FilterDataSourceExtFieldSetup(
            DataSourceExtFieldSetup, Enum::"NPR POS DS Extension Module"::DocImport, POSDataMgt.POSDataSource_BuiltInSale(), ThisExtension(), ExtensionField_OpenOrders());
        if not DataSourceExtFieldSetup.IsEmpty() then begin
            DataSourceExtFieldSetup.SetRange("Exclude from Data Source", false);
            if DataSourceExtFieldSetup.IsEmpty() then
                exit;
        end;

        Extensions.Add(ThisExtension());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', true, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
        DSExtFieldSetupPublic: Codeunit "NPR DS Ext.Field Setup Public";
        POSDataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale() then
            exit;
        if ExtensionName <> ThisExtension() then
            exit;

        Handled := true;

        DSExtFieldSetupPublic.FilterDataSourceExtFieldSetup(
            DataSourceExtFieldSetup, Enum::"NPR POS DS Extension Module"::DocImport, POSDataMgt.POSDataSource_BuiltInSale(), ThisExtension(), ExtensionField_OpenOrders());
        if DataSourceExtFieldSetup.IsEmpty() then begin
            DataSource.AddColumn(ExtensionField_OpenOrders(), DefaultExtensionFieldDescr_OpenOrders(), DataType::String, true);
            exit;
        end;
        DataSourceExtFieldSetup.SetRange("Exclude from Data Source", false);
        if DataSourceExtFieldSetup.FindSet() then
            repeat
                DataSource.AddColumn(DataSourceExtFieldSetup."Exten.Field Instance Name", DataSourceExtFieldSetup."Exten.Field Instance Descript.", DataType::String, true);
            until DataSourceExtFieldSetup.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', true, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
        DSExtFieldSetupPublic: Codeunit "NPR DS Ext.Field Setup Public";
        SalePOS: Record "NPR POS Sale";
        POSDataMgt: Codeunit "NPR POS Data Management";
        LocationFrom: Enum "NPR Location Filter From";
        LocationFilter: Text;
    begin
        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale()) or (ExtensionName <> ThisExtension()) then
            exit;

        Handled := true;

        RecRef.SetTable(SalePOS);

        DSExtFieldSetupPublic.FilterDataSourceExtFieldSetup(
            DataSourceExtFieldSetup, Enum::"NPR POS DS Extension Module"::DocImport, POSDataMgt.POSDataSource_BuiltInSale(), ThisExtension(), ExtensionField_OpenOrders());
        if DataSourceExtFieldSetup.IsEmpty() then begin
            LocationFilter := DSExtFieldSetupPublic.GetDSExtFldLocationFilter(SalePOS, LocationFrom::PosStore, LocationFilter);
            AddExtensionField(ExtensionField_OpenOrders(), LocationFilter, DataRow);
            exit;
        end;
        DataSourceExtFieldSetup.SetRange("Exclude from Data Source", false);
        if DataSourceExtFieldSetup.FindSet() then
            repeat
                DSExtFieldSetupPublic.GetLocationFilterParams(DataSourceExtFieldSetup, LocationFrom, LocationFilter);
                LocationFilter := DSExtFieldSetupPublic.GetDSExtFldLocationFilter(SalePOS, LocationFrom, LocationFilter);
                AddExtensionField(DataSourceExtFieldSetup."Exten.Field Instance Name", LocationFilter, DataRow);
            until DataSourceExtFieldSetup.Next() = 0;
    end;

    local procedure AddExtensionField(FieldName: Text; LocationFilter: Text; DataRow: Codeunit "NPR Data Row")
    var
        SalesHeader: Record "Sales Header";
    begin
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        SalesHeader.ReadIsolation(IsolationLevel::ReadUncommitted);
#ENDIF
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        if LocationFilter <> '' then
            SalesHeader.SetFilter("Location Code", LocationFilter);

        DataRow.Add(FieldName, SalesHeader.Count());
    end;

    procedure GetSupportedDataSourceNameFilter(): Text
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        exit(POSDataMgt.POSDataSource_BuiltInSale());
    end;

    procedure GetSupportedDataSourceExtensionNameList(DataSourceName: Text[50]; var TempExtensionNameList: Record "NPR Retail List")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        ExtensionDescrLbl: Label 'Info about standard BC sales documents.', MaxLength = 250;
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale() then
            exit;
        TempExtensionNameList.Number += 1;
        TempExtensionNameList.Choice := ThisExtension();
        TempExtensionNameList.Value := ExtensionDescrLbl;
        TempExtensionNameList.Insert();
    end;

    procedure GetSupportedExtensionFieldList(DataSourceName: Text[50]; ExtensionName: Text[50]; var TempExtensionNameList: Record "NPR Retail List")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale()) or (ExtensionName <> ThisExtension()) then
            exit;
        TempExtensionNameList.Number += 1;
        TempExtensionNameList.Choice := ExtensionField_OpenOrders();
        TempExtensionNameList.Value := DefaultExtensionFieldDescr_OpenOrders();
        TempExtensionNameList.Insert();
    end;

    procedure ValidateDataSourceExtensionModule(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        DataSourceExtFieldSetup."Data Source Name" := POSDataMgt.POSDataSource_BuiltInSale();
        ValidateDataSourceName(DataSourceExtFieldSetup);
    end;

    procedure ValidateDataSourceName(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    begin
        DataSourceExtFieldSetup."Extension Name" := ThisExtension();
        ValidateExtensionName(DataSourceExtFieldSetup);
    end;

    procedure ValidateExtensionName(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    begin
    end;

    procedure ValidateExtensionField(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    begin
        if DataSourceExtFieldSetup."Exten.Field Instance Name" = '' then
            if DataSourceExtFieldSetup."Extension Field" = ExtensionField_OpenOrders() then begin
                DataSourceExtFieldSetup."Exten.Field Instance Name" := ExtensionField_OpenOrders();
                DataSourceExtFieldSetup."Exten.Field Instance Descript." := DefaultExtensionFieldDescr_OpenOrders();
            end;
    end;

    procedure OpenAdditionalParameterPage(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; EditMode: boolean)
    var
        DSExtFieldSetupPublic: Codeunit "NPR DS Ext.Field Setup Public";
    begin
        DSExtFieldSetupPublic.OpenLocationFilterSetupPage(DataSourceExtFieldSetup, EditMode);
    end;
}