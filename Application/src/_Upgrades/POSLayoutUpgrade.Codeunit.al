codeunit 6184837 "NPR POS Layout Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradePOSLayoutEncoding();
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

    local procedure UpdatePOSLayoutEncoding()
    var
        POSLayout: Record "NPR POS Layout";
        CurrInStream: InStream;
        CurrOutStream: OutStream;
        LayoutText: Text;
    begin
        POSLayout.Reset();
        if not POSLayout.FindSet(true) then
            exit;

        repeat
            if POSLayout."Frontend Properties".HasValue() then begin
                Clear(CurrInStream);
                Clear(CurrOutStream);

                POSLayout.CalcFields("Frontend Properties");
                POSLayout."Frontend Properties".CreateInStream(CurrInStream);
                POSLayout."Frontend Properties".CreateOutStream(CurrOutStream, TextEncoding::UTF8);

                CurrInStream.Read(LayoutText);
                CurrOutStream.Write(LayoutText);
                POSLayout.Modify();
            end;
        until POSLayout.Next() = 0;

    end;
}
