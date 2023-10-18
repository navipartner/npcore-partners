interface "NPR POS DS Exten. Field Setup"
{
    procedure GetSupportedDataSourceNameFilter(): Text
    procedure GetSupportedDataSourceExtensionNameList(DataSourceName: Text[50]; var TempExtensionNameList: Record "NPR Retail List")
    procedure GetSupportedExtensionFieldList(DataSourceName: Text[50]; ExtensionName: Text[50]; var TempExtensionNameList: Record "NPR Retail List")
    procedure ValidateDataSourceExtensionModule(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    procedure ValidateDataSourceName(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    procedure ValidateExtensionName(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    procedure ValidateExtensionField(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    procedure OpenAdditionalParameterPage(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; EditMode: boolean)
}