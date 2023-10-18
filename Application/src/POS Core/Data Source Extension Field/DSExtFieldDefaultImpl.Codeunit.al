codeunit 6184502 "NPR DS Ext.Field Default Impl." implements "NPR POS DS Exten. Field Setup"
{
    Access = Internal;

    procedure GetSupportedDataSourceNameFilter(): Text
    begin
        exit('')
    end;

    procedure GetSupportedDataSourceExtensionNameList(DataSourceName: Text[50]; var TempExtensionNameList: Record "NPR Retail List")
    begin
    end;

    procedure GetSupportedExtensionFieldList(DataSourceName: Text[50]; ExtensionName: Text[50]; var TempExtensionNameList: Record "NPR Retail List")
    begin
    end;

    procedure ValidateDataSourceExtensionModule(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    begin
    end;

    procedure ValidateDataSourceName(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    begin
    end;

    procedure ValidateExtensionName(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    begin
    end;

    procedure ValidateExtensionField(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    begin
    end;

    procedure OpenAdditionalParameterPage(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; EditMode: boolean)
    begin
        DataSourceExtFieldSetup.FieldError("Extension Module");
    end;
}