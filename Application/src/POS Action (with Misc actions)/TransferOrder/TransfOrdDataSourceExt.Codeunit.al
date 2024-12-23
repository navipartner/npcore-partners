codeunit 6248196 "NPR Transf.Ord. DataSource Ext" implements "NPR POS DS Exten. Field Setup"
{
    Access = Internal;

    local procedure ThisExtension(): Text[50]
    begin
        exit('TransferOrder');
    end;

    local procedure ExtensionField_ProcessedOrdersFromExists(): Text[50]
    begin
        exit('ProcessedOrdersFromExists');
    end;

    local procedure ExtensionField_ProcessedOrdersFromQty(): Text[50]
    begin
        exit('ProcessedOrdersFromQty');
    end;

    local procedure ExtensionField_ProcessedOrdersToExists(): Text[50]
    begin
        exit('ProcessedOrdersToExists');
    end;

    local procedure ExtensionField_ProcessedOrdersToQty(): Text[50]
    begin
        exit('ProcessedOrdersToQty');
    end;

    local procedure DefaultExtensionFieldDescr_ProcessedOrdersFromExist(): Text[100]
    var
        ExtFieldDescrLbl: Label 'Processed Orders From Exists', MaxLength = 100;
    begin
        exit(ExtFieldDescrLbl);
    end;

    local procedure DefaultExtensionFieldDescr_ProcessedOrdersFromQty(): Text[100]
    var
        ExtFieldDescrLbl: Label 'Processed Orders From Qty.', MaxLength = 100;
    begin
        exit(ExtFieldDescrLbl);
    end;

    local procedure DefaultExtensionFieldDescr_ProcessedOrdersToExist(): Text[100]
    var
        ExtFieldDescrLbl: Label 'Processed Orders To Exists', MaxLength = 100;
    begin
        exit(ExtFieldDescrLbl);
    end;

    local procedure DefaultExtensionFieldDescr_ProcessedOrdersToQty(): Text[100]
    var
        ExtFieldDescrLbl: Label 'Processed Orders To Qty.', MaxLength = 100;
    begin
        exit(ExtFieldDescrLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscover(DataSourceName: Text; Extensions: List of [Text])
    var
        TransferOrd: Record "Transfer Header";
        POSDataMgt: Codeunit "NPR POS Data Management";
        RegisterExtension: Boolean;
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale() then
            exit;
        if TransferOrd.IsEmpty() then
            exit;

        RegisterExtension := ExtentionFieldEnabled(ExtensionField_ProcessedOrdersFromExists());
        if not RegisterExtension then
            RegisterExtension := ExtentionFieldEnabled(ExtensionField_ProcessedOrdersFromQty());
        if not RegisterExtension then
            RegisterExtension := ExtentionFieldEnabled(ExtensionField_ProcessedOrdersToExists());
        if not RegisterExtension then
            RegisterExtension := ExtentionFieldEnabled(ExtensionField_ProcessedOrdersToQty());

        if RegisterExtension then
            Extensions.Add('TransferOrder');
    end;

    local procedure ExtentionFieldEnabled(ExtensionField: Text[50]): Boolean
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
        DSExtFieldSetupPublic: Codeunit "NPR DS Ext.Field Setup Public";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        DSExtFieldSetupPublic.FilterDataSourceExtFieldSetup(
            DataSourceExtFieldSetup, Enum::"NPR POS DS Extension Module"::TransferOrder, POSDataMgt.POSDataSource_BuiltInSale(), ThisExtension(), ExtensionField);
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

        AddDataSourceColumns(ExtensionField_ProcessedOrdersFromExists(), DefaultExtensionFieldDescr_ProcessedOrdersFromExist(), DataType::Boolean, DataSource);
        AddDataSourceColumns(ExtensionField_ProcessedOrdersFromQty(), DefaultExtensionFieldDescr_ProcessedOrdersFromQty(), DataType::Integer, DataSource);
        AddDataSourceColumns(ExtensionField_ProcessedOrdersToExists(), DefaultExtensionFieldDescr_ProcessedOrdersToExist(), DataType::Boolean, DataSource);
        AddDataSourceColumns(ExtensionField_ProcessedOrdersToQty(), DefaultExtensionFieldDescr_ProcessedOrdersToQty(), DataType::Integer, DataSource);
    end;

    local procedure AddDataSourceColumns(ExtensionField: Text[50]; ExtensionFieldDescr: Text[100]; DataType: Enum "NPR Data Type"; var DataSource: Codeunit "NPR Data Source")
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
        DSExtFieldSetupPublic: Codeunit "NPR DS Ext.Field Setup Public";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        DSExtFieldSetupPublic.FilterDataSourceExtFieldSetup(
            DataSourceExtFieldSetup, Enum::"NPR POS DS Extension Module"::TransferOrder, POSDataMgt.POSDataSource_BuiltInSale(), ThisExtension(), ExtensionField);
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
        Setup: Codeunit "NPR POS Setup";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale() then
            exit;
        if ExtensionName <> ThisExtension() then
            exit;

        Handled := true;
        POSSession.GetSetup(Setup);
        RecRef.SetTable(SalePOS);

        AddExtensionField(SalePOS, ExtensionField_ProcessedOrdersFromExists(), DataRow);
        AddExtensionField(SalePOS, ExtensionField_ProcessedOrdersFromQty(), DataRow);
        AddExtensionField(SalePOS, ExtensionField_ProcessedOrdersToExists(), DataRow);
        AddExtensionField(SalePOS, ExtensionField_ProcessedOrdersToQty(), DataRow);
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
            DataSourceExtFieldSetup, Enum::"NPR POS DS Extension Module"::TransferOrder, POSDataMgt.POSDataSource_BuiltInSale(), ThisExtension(), ExtensionField);
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
            ExtensionField_ProcessedOrdersFromExists():
                DataRow.Add(ExtensionFieldInstanceName, GetProcessedOrdersFromExists(LocationFilter));
            ExtensionField_ProcessedOrdersFromQty():
                DataRow.Add(ExtensionFieldInstanceName, GetProcessedOrdersFromQty(LocationFilter));
            ExtensionField_ProcessedOrdersToExists():
                DataRow.Add(ExtensionFieldInstanceName, GetProcessedOrdersToExists(LocationFilter));
            ExtensionField_ProcessedOrdersToQty():
                DataRow.Add(ExtensionFieldInstanceName, GetProcessedOrdersToQty(LocationFilter));
        end;
    end;

    local procedure GetProcessedOrdersFromExists(LocationFilter: Text): Boolean
    var
        TransferHeader: Record "Transfer Header";
    begin
        TransferHeader.SetFilter("Transfer-from Code", LocationFilter);
        exit(not TransferHeader.IsEmpty);
    end;

    local procedure GetProcessedOrdersFromQty(LocationFilter: Text): Integer
    var
        TransferHeader: Record "Transfer Header";
    begin
        TransferHeader.SetFilter("Transfer-from Code", LocationFilter);
        exit(TransferHeader.Count());
    end;

    local procedure GetProcessedOrdersToExists(LocationFilter: Text): Boolean
    var
        TransferHeader: Record "Transfer Header";
    begin
        TransferHeader.SetFilter("Transfer-to Code", LocationFilter);
        exit(not TransferHeader.IsEmpty());
    end;

    local procedure GetProcessedOrdersToQty(LocationFilter: Text): Integer
    var
        TransferHeader: Record "Transfer Header";
    begin
        TransferHeader.SetFilter("Transfer-to Code", LocationFilter);
        exit(TransferHeader.Count());
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
        ExtensionDescrLbl: Label 'Info about transfer orders.', MaxLength = 250;
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

        AddSupportedExtensionField(ExtensionField_ProcessedOrdersFromExists(), DefaultExtensionFieldDescr_ProcessedOrdersFromExist(), TempExtensionNameList);
        AddSupportedExtensionField(ExtensionField_ProcessedOrdersFromQty(), DefaultExtensionFieldDescr_ProcessedOrdersFromQty(), TempExtensionNameList);
        AddSupportedExtensionField(ExtensionField_ProcessedOrdersToExists(), DefaultExtensionFieldDescr_ProcessedOrdersToExist(), TempExtensionNameList);
        AddSupportedExtensionField(ExtensionField_ProcessedOrdersToQty(), DefaultExtensionFieldDescr_ProcessedOrdersToQty(), TempExtensionNameList);
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
                ExtensionField_ProcessedOrdersFromExists():
                    begin
                        DataSourceExtFieldSetup."Exten.Field Instance Name" := ExtensionField_ProcessedOrdersFromExists();
                        DataSourceExtFieldSetup."Exten.Field Instance Descript." := DefaultExtensionFieldDescr_ProcessedOrdersFromExist();
                    end;
                ExtensionField_ProcessedOrdersFromQty():
                    begin
                        DataSourceExtFieldSetup."Exten.Field Instance Name" := ExtensionField_ProcessedOrdersFromQty();
                        DataSourceExtFieldSetup."Exten.Field Instance Descript." := DefaultExtensionFieldDescr_ProcessedOrdersFromQty();
                    end;
                ExtensionField_ProcessedOrdersToExists():
                    begin
                        DataSourceExtFieldSetup."Exten.Field Instance Name" := ExtensionField_ProcessedOrdersToExists();
                        DataSourceExtFieldSetup."Exten.Field Instance Descript." := DefaultExtensionFieldDescr_ProcessedOrdersToExist();
                    end;
                ExtensionField_ProcessedOrdersToQty():
                    begin
                        DataSourceExtFieldSetup."Exten.Field Instance Name" := ExtensionField_ProcessedOrdersToQty();
                        DataSourceExtFieldSetup."Exten.Field Instance Descript." := DefaultExtensionFieldDescr_ProcessedOrdersToQty();
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