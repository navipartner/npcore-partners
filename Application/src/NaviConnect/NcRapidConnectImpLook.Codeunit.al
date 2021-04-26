codeunit 6151093 "NPR Nc RapidConnect Imp. Look."
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
        LookupRapidConnect(Rec);
    end;

    local procedure LookupRapidConnect(NcImportEntry: Record "NPR Nc Import Entry")
    var
        ConfigPackage: Record "Config. Package";
        TempConfigPackage: Record "Config. Package" temporary;
        PageMgt: Codeunit "Page Management";
        FirstPackageCode: Code[20];
        PageId: Integer;
    begin
        if not FindConfPackages(NcImportEntry, TempConfigPackage) then
            exit;

        TempConfigPackage.FindFirst();
        FirstPackageCode := TempConfigPackage.Code;
        TempConfigPackage.FindLast();

        if FirstPackageCode = TempConfigPackage.Code then begin
            PageId := PageMgt.GetDefaultCardPageID(DATABASE::"Config. Package");
            ConfigPackage.Get(TempConfigPackage.Code);
            PAGE.Run(PageId, ConfigPackage);
            exit;
        end;

        PAGE.Run(0, TempConfigPackage);
    end;

    local procedure FindConfPackages(NcImportEntry: Record "NPR Nc Import Entry"; var TempConfigPackage: Record "Config. Package" temporary): Boolean
    var
        ConfigPackage: Record "Config. Package";
        NcRapidConnectSetup: Record "NPR Nc RapidConnect Setup";
    begin
        NcRapidConnectSetup.SetFilter("Package Code", '<>%1', '');
        NcRapidConnectSetup.SetRange("Import Type", NcImportEntry."Import Type");
        if not NcRapidConnectSetup.FindSet() then
            exit;

        repeat
            if (not TempConfigPackage.Get(NcRapidConnectSetup."Package Code")) and ConfigPackage.Get(NcRapidConnectSetup."Package Code") then begin
                TempConfigPackage.Init();
                TempConfigPackage := ConfigPackage;
                TempConfigPackage.Insert();
            end;
        until NcRapidConnectSetup.Next() = 0;
        exit(TempConfigPackage.FindFirst());
    end;
}

