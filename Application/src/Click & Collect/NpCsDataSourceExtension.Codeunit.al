codeunit 6184503 "NPR NpCs Data Source Extension" implements "NPR POS DS Exten. Field Setup"
{
    Access = Internal;

    local procedure ThisExtension(): Text[50]
    begin
        exit('CollectInStore');
    end;

    local procedure ExtensionField_UnprocessedOrdersExist(): Text[50]
    begin
        exit('UnprocessedOrdersExist');
    end;

    local procedure ExtensionField_UnprocessedOrdersQty(): Text[50]
    begin
        exit('UnprocessedOrdersQty');
    end;

    local procedure ExtensionField_ProcessedOrdersExist(): Text[50]
    begin
        exit('ProcessedOrdersExist');
    end;

    local procedure ExtensionField_ProcessedOrdersQty(): Text[50]
    begin
        exit('ProcessedOrdersQty');
    end;

    local procedure DefaultExtensionFieldDescr_UnprocessedOrdersExist(): Text[100]
    var
        ExtFieldDescrLbl: Label 'Unprocessed orders exist', MaxLength = 100;
    begin
        exit(ExtFieldDescrLbl);
    end;

    local procedure DefaultExtensionFieldDescr_UnprocessedOrdersQty(): Text[100]
    var
        ExtFieldDescrLbl: Label 'Number of unprocessed orders', MaxLength = 100;
    begin
        exit(ExtFieldDescrLbl);
    end;

    local procedure DefaultExtensionFieldDescr_ProcessedOrdersExist(): Text[100]
    var
        ExtFieldDescrLbl: Label 'Processed orders exist', MaxLength = 100;
    begin
        exit(ExtFieldDescrLbl);
    end;

    local procedure DefaultExtensionFieldDescr_ProcessedOrdersQty(): Text[100]
    var
        ExtFieldDescrLbl: Label 'Number of processed orders', MaxLength = 100;
    begin
        exit(ExtFieldDescrLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscover(DataSourceName: Text; Extensions: List of [Text])
    var
        NpCsStore: Record "NPR NpCs Store";
        POSDataMgt: Codeunit "NPR POS Data Management";
        RegisterExtension: Boolean;
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale() then
            exit;
        if NpCsStore.IsEmpty() then
            exit;

        RegisterExtension := ExtentionFieldEnabled(ExtensionField_UnprocessedOrdersExist());
        if not RegisterExtension then
            RegisterExtension := ExtentionFieldEnabled(ExtensionField_UnprocessedOrdersQty());
        if not RegisterExtension then
            RegisterExtension := ExtentionFieldEnabled(ExtensionField_ProcessedOrdersExist());
        if not RegisterExtension then
            RegisterExtension := ExtentionFieldEnabled(ExtensionField_ProcessedOrdersQty());

        if RegisterExtension then
            Extensions.Add(ThisExtension());
    end;

    local procedure ExtentionFieldEnabled(ExtensionField: Text[50]): Boolean
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
        DSExtFieldSetupPublic: Codeunit "NPR DS Ext.Field Setup Public";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        DSExtFieldSetupPublic.FilterDataSourceExtFieldSetup(
            DataSourceExtFieldSetup, Enum::"NPR POS DS Extension Module"::ClickCollect, POSDataMgt.POSDataSource_BuiltInSale(), ThisExtension(), ExtensionField);
        if DataSourceExtFieldSetup.IsEmpty() then
            exit(true);
        DataSourceExtFieldSetup.SetRange("Exclude from Data Source", false);
        exit(not DataSourceExtFieldSetup.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale() then
            exit;
        if ExtensionName <> ThisExtension() then
            exit;

        Handled := true;

        AddDataSourceColumns(ExtensionField_UnprocessedOrdersExist(), DefaultExtensionFieldDescr_UnprocessedOrdersExist(), DataType::Boolean, DataSource);
        AddDataSourceColumns(ExtensionField_UnprocessedOrdersQty(), DefaultExtensionFieldDescr_UnprocessedOrdersQty(), DataType::Integer, DataSource);
        AddDataSourceColumns(ExtensionField_ProcessedOrdersExist(), DefaultExtensionFieldDescr_ProcessedOrdersExist(), DataType::Boolean, DataSource);
        AddDataSourceColumns(ExtensionField_ProcessedOrdersQty(), DefaultExtensionFieldDescr_ProcessedOrdersQty(), DataType::Integer, DataSource);
    end;

    local procedure AddDataSourceColumns(ExtensionField: Text[50]; ExtensionFieldDescr: Text[100]; DataType: Enum "NPR Data Type"; var DataSource: Codeunit "NPR Data Source")
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
        DSExtFieldSetupPublic: Codeunit "NPR DS Ext.Field Setup Public";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        DSExtFieldSetupPublic.FilterDataSourceExtFieldSetup(
            DataSourceExtFieldSetup, Enum::"NPR POS DS Extension Module"::ClickCollect, POSDataMgt.POSDataSource_BuiltInSale(), ThisExtension(), ExtensionField);
        if DataSourceExtFieldSetup.IsEmpty() then begin
            DataSource.AddColumn(ExtensionField, ExtensionFieldDescr, DataType, false);
            exit;
        end;
        DataSourceExtFieldSetup.SetRange("Exclude from Data Source", false);
        if DataSourceExtFieldSetup.FindSet() then
            repeat
                DataSource.AddColumn(DataSourceExtFieldSetup."Exten.Field Instance Name", DataSourceExtFieldSetup."Exten.Field Instance Descript.", DataType, false);
            until DataSourceExtFieldSetup.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale() then
            exit;
        if ExtensionName <> ThisExtension() then
            exit;

        Handled := true;

        RecRef.SetTable(SalePOS);

        AddExtensionField(SalePOS, ExtensionField_UnprocessedOrdersExist(), DataRow);
        AddExtensionField(SalePOS, ExtensionField_UnprocessedOrdersQty(), DataRow);
        AddExtensionField(SalePOS, ExtensionField_ProcessedOrdersExist(), DataRow);
        AddExtensionField(SalePOS, ExtensionField_ProcessedOrdersQty(), DataRow);
    end;

    local procedure AddExtensionField(SalePOS: Record "NPR POS Sale"; ExtensionField: Text[50]; DataRow: Codeunit "NPR Data Row")
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
        DSExtFieldSetupPublic: Codeunit "NPR DS Ext.Field Setup Public";
        POSDataMgt: Codeunit "NPR POS Data Management";
        LocationFrom: Enum "NPR Location Filter From";
        LocationFilter: Text;
    begin
        DSExtFieldSetupPublic.FilterDataSourceExtFieldSetup(
            DataSourceExtFieldSetup, Enum::"NPR POS DS Extension Module"::ClickCollect, POSDataMgt.POSDataSource_BuiltInSale(), ThisExtension(), ExtensionField);
        if DataSourceExtFieldSetup.IsEmpty() then begin
            LocationFilter := DSExtFieldSetupPublic.GetDSExtFldLocationFilter(SalePOS, LocationFrom::PosStore, LocationFilter);
            AddExtensionField(ExtensionField, ExtensionField, LocationFilter, DataRow);
            exit;
        end;
        DataSourceExtFieldSetup.SetRange("Exclude from Data Source", false);
        if DataSourceExtFieldSetup.FindSet() then
            repeat
                DSExtFieldSetupPublic.GetLocationFilterParams(DataSourceExtFieldSetup, LocationFrom, LocationFilter);
                LocationFilter := DSExtFieldSetupPublic.GetDSExtFldLocationFilter(SalePOS, LocationFrom, LocationFilter);
                AddExtensionField(DataSourceExtFieldSetup."Extension Field", DataSourceExtFieldSetup."Exten.Field Instance Name", LocationFilter, DataRow);
            until DataSourceExtFieldSetup.Next() = 0;
    end;

    local procedure AddExtensionField(ExtensionField: Text[50]; ExtensionFieldInstanceName: Text[50]; LocationFilter: Text; DataRow: Codeunit "NPR Data Row")
    begin
        case ExtensionField of
            ExtensionField_UnprocessedOrdersExist():
                DataRow.Add(ExtensionFieldInstanceName, GetUnprocessedOrdersExists(LocationFilter));
            ExtensionField_UnprocessedOrdersQty():
                DataRow.Add(ExtensionFieldInstanceName, GetUnprocessedOrdersQty(LocationFilter));
            ExtensionField_ProcessedOrdersExist():
                DataRow.Add(ExtensionFieldInstanceName, GetProcessedOrdersExists(LocationFilter));
            ExtensionField_ProcessedOrdersQty():
                DataRow.Add(ExtensionFieldInstanceName, GetProcessedOrdersQty(LocationFilter));
        end;
    end;

    local procedure GetUnprocessedOrdersExists(LocationFilter: Text): Boolean
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        SetUnprocessedFilter(LocationFilter, NpCsDocument);
        exit(not NpCsDocument.IsEmpty());
    end;

    local procedure GetUnprocessedOrdersQty(LocationFilter: Text): Integer
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsPOSActionEvents: Codeunit "NPR NpCs POS Action Events";
        UnprocessedOrderQty: Decimal;
        IsHandled: Boolean;
    begin
        NpCsPOSActionEvents.OnBeforeGetUnprocessedOrderQty(LocationFilter, UnprocessedOrderQty, IsHandled);
        if IsHandled then
            exit(UnprocessedOrderQty);
        SetUnprocessedFilter(LocationFilter, NpCsDocument);
        exit(NpCsDocument.Count());
    end;

    procedure SetUnprocessedFilter(LocationFilter: Text; var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsPOSActionEvents: Codeunit "NPR NpCs POS Action Events";
        IsHandled: Boolean;
    begin
        NpCsPOSActionEvents.OnBeforeSetUnprocessedFilter(LocationFilter, NpCsDocument, IsHandled);
        if IsHandled then
            exit;
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Processing Status", NpCsDocument."Processing Status"::Pending);
        NpCsDocument.SetRange("Delivery Status", NpCsDocument."Delivery Status"::" ");
        NpCsDocument.SetFilter("Location Code", LocationFilter);
    end;

    local procedure GetProcessedOrdersExists(LocationFilter: Text): Boolean
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        SetProcessedFilter(LocationFilter, NpCsDocument);
        exit(not NpCsDocument.IsEmpty());
    end;

    local procedure GetProcessedOrdersQty(LocationFilter: Text): Integer
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        SetProcessedFilter(LocationFilter, NpCsDocument);
        exit(NpCsDocument.Count());
    end;

    local procedure SetProcessedFilter(LocationFilter: Text; var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsPOSActionEvents: Codeunit "NPR NpCs POS Action Events";
        IsHandled: Boolean;
    begin
        NpCsPOSActionEvents.OnBeforeSetProcessedFilter(LocationFilter, NpCsDocument, IsHandled);
        if IsHandled then
            exit;
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Processing Status", NpCsDocument."Processing Status"::Confirmed);
        NpCsDocument.SetRange("Delivery Status", NpCsDocument."Delivery Status"::Ready);
        NpCsDocument.SetFilter("Location Code", LocationFilter);
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
        ExtensionDescrLbl: Label 'Info about click & collect documents.', MaxLength = 250;
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
        AddSupportedExtensionField(ExtensionField_UnprocessedOrdersExist(), DefaultExtensionFieldDescr_UnprocessedOrdersExist(), TempExtensionNameList);
        AddSupportedExtensionField(ExtensionField_UnprocessedOrdersQty(), DefaultExtensionFieldDescr_UnprocessedOrdersQty(), TempExtensionNameList);
        AddSupportedExtensionField(ExtensionField_ProcessedOrdersExist(), DefaultExtensionFieldDescr_ProcessedOrdersExist(), TempExtensionNameList);
        AddSupportedExtensionField(ExtensionField_ProcessedOrdersQty(), DefaultExtensionFieldDescr_ProcessedOrdersQty(), TempExtensionNameList);
    end;

    local procedure AddSupportedExtensionField(FieldName: Text[50]; FieldDescription: Text[100]; var TempExtensionNameList: Record "NPR Retail List")
    begin
        TempExtensionNameList.Number += 1;
        TempExtensionNameList.Choice := FieldName;
        TempExtensionNameList.Value := FieldDescription;
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
            case DataSourceExtFieldSetup."Extension Field" of
                ExtensionField_UnprocessedOrdersExist():
                    begin
                        DataSourceExtFieldSetup."Exten.Field Instance Name" := ExtensionField_UnprocessedOrdersExist();
                        DataSourceExtFieldSetup."Exten.Field Instance Descript." := DefaultExtensionFieldDescr_UnprocessedOrdersExist();
                    end;
                ExtensionField_UnprocessedOrdersQty():
                    begin
                        DataSourceExtFieldSetup."Exten.Field Instance Name" := ExtensionField_UnprocessedOrdersQty();
                        DataSourceExtFieldSetup."Exten.Field Instance Descript." := DefaultExtensionFieldDescr_UnprocessedOrdersQty();
                    end;
                ExtensionField_ProcessedOrdersExist():
                    begin
                        DataSourceExtFieldSetup."Exten.Field Instance Name" := ExtensionField_ProcessedOrdersExist();
                        DataSourceExtFieldSetup."Exten.Field Instance Descript." := DefaultExtensionFieldDescr_ProcessedOrdersExist();
                    end;
                ExtensionField_ProcessedOrdersQty():
                    begin
                        DataSourceExtFieldSetup."Exten.Field Instance Name" := ExtensionField_ProcessedOrdersQty();
                        DataSourceExtFieldSetup."Exten.Field Instance Descript." := DefaultExtensionFieldDescr_ProcessedOrdersQty();
                    end;
            end;
    end;

    procedure OpenAdditionalParameterPage(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; EditMode: boolean)
    var
        DSExtFieldSetupPublic: Codeunit "NPR DS Ext.Field Setup Public";
    begin
        DSExtFieldSetupPublic.OpenLocationFilterSetupPage(DataSourceExtFieldSetup, EditMode);
    end;
}