codeunit 6151094 "NPR Nc RapidConnect Apply Pckg"
{
    TableNo = "NPR Nc RapidConnect Setup";

    trigger OnRun()
    var
        NcRapidConnectSetup: Record "NPR Nc RapidConnect Setup";
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        NcRapidConnectSetup.Copy(Rec);
        if not NcRapidConnectSetup.FindSet() then
            exit;

        repeat
            DataLogMgt.DisableDataLog(NcRapidConnectSetup."Disable Data Log on Import");
            ApplyXmlPackage(NcRapidConnectSetup);
        until NcRapidConnectSetup.Next() = 0;

        DataLogMgt.DisableDataLog(false);
    end;

    local procedure ApplyXmlPackage(NcRapidConnectSetup: Record "NPR Nc RapidConnect Setup")
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageMgt: Codeunit "Config. Package Management";
    begin
        if NcRapidConnectSetup."Package Code" = '' then
            exit;
        if not NcRapidConnectSetup."Apply Package" then
            exit;

        ConfigPackage.Get(NcRapidConnectSetup."Package Code");
        ConfigPackageTable.SetRange("Package Code", NcRapidConnectSetup."Package Code");
        if ConfigPackage."Exclude Config. Tables" then begin
            ConfigPackageTable.FilterGroup(40);
            ConfigPackageTable.SetFilter("Table ID", '<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8',
              DATABASE::"Config. Template Header", DATABASE::"Config. Template Line",
              DATABASE::"Config. Questionnaire", DATABASE::"Config. Question Area", DATABASE::"Config. Question",
              DATABASE::"Config. Line", DATABASE::"Config. Package Filter", DATABASE::"Config. Field Mapping");
        end;

        ConfigPackageTable.FilterGroup(41);
        ConfigPackageTable.SetFilter("Table ID", TableIdFilter);

        ConfigPackageMgt.SetHideDialog(not UseDialog);
        ConfigPackageMgt.ApplyPackage(ConfigPackage, ConfigPackageTable, false);
    end;

    procedure SetProcessingOptions(TableIdFilterIn: Text; UseDialogIn: Boolean)
    begin
        TableIdFilter := TableIdFilterIn;
        UseDialog := UseDialogIn;
    end;

    var
        TableIdFilter: Text;
        UseDialog: Boolean;
}