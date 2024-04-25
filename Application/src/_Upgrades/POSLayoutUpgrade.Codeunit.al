codeunit 6184837 "NPR POS Layout Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradePOSLayoutEncoding();
        UpgradeArchivedPOSLayoutEncoding();
    end;

    local procedure UpgradePOSLayoutEncoding()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagDefinitions: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR POS Layout Upgrade', 'UpgradePOSLayoutEncoding');

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR POS Layout Upgrade", 'UpgradePOSLayoutEncoding')) then begin
            UpdatePOSLayoutEncoding();
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR POS Layout Upgrade", 'UpgradePOSLayoutEncoding'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeArchivedPOSLayoutEncoding()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagDefinitions: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR POS Layout Upgrade', 'UpgradeArchivedPOSLayoutEncoding');

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR POS Layout Upgrade", 'UpgradeArchivedPOSLayoutEncoding')) then begin
            UpdateArchivedPOSLayoutEncoding();
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR POS Layout Upgrade", 'UpgradeArchivedPOSLayoutEncoding'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdatePOSLayoutEncoding()
    var
        POSLayout: Record "NPR POS Layout";
        CurrOutStream: OutStream;
        LayoutText: Text;
    begin
        POSLayout.Reset();
        if not POSLayout.FindSet(true) then
            exit;

        repeat
            if POSLayout."Frontend Properties".HasValue() then begin

                POSLayout.CalcFields("Frontend Properties");
                Clear(LayoutText);

                if not TryReadPOSLayoutBlobWithEncoding(POSLayout, LayoutText, TextEncoding::UTF8) then
                    if TryReadPOSLayoutBlobWithEncoding(POSLayout, LayoutText, TextEncoding::MSDos) then begin

                        Clear(CurrOutStream);
                        POSLayout."Frontend Properties".CreateOutStream(CurrOutStream, TextEncoding::UTF8);

                        CurrOutStream.Write(LayoutText);
                        POSLayout.Modify();
                    end;
            end;
        until POSLayout.Next() = 0;

    end;


    local procedure UpdateArchivedPOSLayoutEncoding()
    var
        POSLayoutArchive: Record "NPR POS Layout Archive";
        CurrOutStream: OutStream;
        LayoutText: Text;
    begin
        POSLayoutArchive.Reset();
        if not POSLayoutArchive.FindSet(true) then
            exit;

        repeat
            if POSLayoutArchive."Frontend Properties".HasValue() then begin

                POSLayoutArchive.CalcFields("Frontend Properties");
                Clear(LayoutText);

                if not TryReadBlobWithEncoding(POSLayoutArchive, LayoutText, TextEncoding::UTF8) then
                    if TryReadBlobWithEncoding(POSLayoutArchive, LayoutText, TextEncoding::MSDos) then begin

                        Clear(CurrOutStream);
                        POSLayoutArchive."Frontend Properties".CreateOutStream(CurrOutStream, TextEncoding::UTF8);

                        CurrOutStream.Write(LayoutText);
                        POSLayoutArchive.Modify();
                    end;
            end;
        until POSLayoutArchive.Next() = 0;

    end;

    [TryFunction]
    local procedure TryReadBlobWithEncoding(var POSLayoutArchive: Record "NPR POS Layout Archive"; var PropertiesString: Text; Encoding: TextEncoding)
    var
        CurrentInstream: InStream;
    begin
        POSLayoutArchive."Frontend Properties".CreateInStream(CurrentInstream, Encoding);
        CurrentInstream.Read(PropertiesString);
    end;

    [TryFunction]
    local procedure TryReadPOSLayoutBlobWithEncoding(var POSLayout: Record "NPR POS Layout"; var PropertiesString: Text; Encoding: TextEncoding)
    var
        CurrentInstream: InStream;
    begin
        POSLayout."Frontend Properties".CreateInStream(CurrentInstream, Encoding);
        CurrentInstream.Read(PropertiesString);
    end;
}
