codeunit 6060095 "NPR UPG Scanner Stations"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";

    trigger OnUpgradePerCompany()
    var
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Scanner Stations', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Scanner Stations")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Scanner Stations"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        UpgradeScannerStations();
        UpgradeServiceSetup();
    end;

    local procedure UpgradeScannerStations()
    var
        ScannerStations: Record "NPR MM Admis. Scanner Stations";
        IStream: InStream;
        ModifyRec: Boolean;
    begin
        if ScannerStations.IsEmpty() then
            exit;

        if ScannerStations.FindSet() then
            repeat
                ModifyRec := false;
                if ScannerStations."Guest Avatar".HasValue() then begin
                    ScannerStations.CalcFields("Guest Avatar");
                    ScannerStations."Guest Avatar".CreateInStream(IStream);
                    ScannerStations."Guest Avatar Image".ImportStream(IStream, ScannerStations.FieldName("Guest Avatar Image"));
                    ModifyRec := true;
                end;
                if ScannerStations."Turnstile Default Image".HasValue() then begin
                    ScannerStations.CalcFields("Turnstile Default Image");
                    ScannerStations."Turnstile Default Image".CreateInStream(IStream);
                    ScannerStations."Default Turnstile Image".ImportStream(IStream, ScannerStations.FieldName("Turnstile Default Image"));
                    ModifyRec := true;
                end;
                if ScannerStations."Turnstile Error Image".HasValue() then begin
                    ScannerStations.CalcFields("Turnstile Error Image");
                    ScannerStations."Turnstile Error Image".CreateInStream(IStream);
                    ScannerStations."Error Image of Turnstile".ImportStream(IStream, ScannerStations.FieldName("Turnstile Error Image"));
                    ModifyRec := true;
                end;
                if ModifyRec then
                    ScannerStations.Modify();
            until ScannerStations.Next() = 0;
    end;

    local procedure UpgradeServiceSetup()
    var
        ServiceSetup: Record "NPR MM Admis. Service Setup";
        IStream: InStream;
        ModifyRec: Boolean;
    begin
        if ServiceSetup.IsEmpty() then
            exit;

        if ServiceSetup.FindSet() then
            repeat
                ModifyRec := false;
                if ServiceSetup."Guest Avatar".HasValue() then begin
                    ServiceSetup.CalcFields("Guest Avatar");
                    ServiceSetup."Guest Avatar".CreateInStream(IStream);
                    ServiceSetup."Guest Avatar Image".ImportStream(IStream, ServiceSetup.FieldName("Guest Avatar Image"));
                    ModifyRec := true;
                end;
                if ServiceSetup."Turnstile Default Image".HasValue() then begin
                    ServiceSetup.CalcFields("Turnstile Default Image");
                    ServiceSetup."Turnstile Default Image".CreateInStream(IStream);
                    ServiceSetup."Default Turnstile Image".ImportStream(IStream, ServiceSetup.FieldName("Turnstile Default Image"));
                    ModifyRec := true;
                end;
                if ServiceSetup."Turnstile Error Image".HasValue() then begin
                    ServiceSetup.CalcFields("Turnstile Error Image");
                    ServiceSetup."Turnstile Error Image".CreateInStream(IStream);
                    ServiceSetup."Error Image of Turnstile".ImportStream(IStream, ServiceSetup.FieldName("Turnstile Error Image"));
                    ModifyRec := true;
                end;
                if ModifyRec then
                    ServiceSetup.Modify();
            until ServiceSetup.Next() = 0;
    end;

}
