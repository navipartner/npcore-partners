#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6151155 "NPR UPG Digital Notif. Entr."
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeSourceDocumentIdOnDigitalNotifEntries();
    end;

    local procedure UpgradeSourceDocumentIdOnDigitalNotifEntries()
    var
        DigitalNotifEntry: Record "NPR Digital Notification Entry";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        NullGuid: Guid;
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Digital Notif. Entr.', 'UpgradeSourceDocumentIdOnDigitalNotifEntries');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeSourceDocumentIdOnDigitalNotifEntries')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        Clear(NullGuid);
        DigitalNotifEntry.SetRange("Source Document Id", NullGuid);
        if DigitalNotifEntry.FindSet(true) then
            repeat
                case DigitalNotifEntry."Document Type" of
                    "NPR Digital Document Type"::Invoice:
                        if SalesInvHeader.Get(DigitalNotifEntry."Posted Document No.") then
                            DigitalNotifEntry."Source Document Id" := SalesInvHeader.SystemId;
                    "NPR Digital Document Type"::"Credit Memo":
                        if SalesCrMemoHeader.Get(DigitalNotifEntry."Posted Document No.") then
                            DigitalNotifEntry."Source Document Id" := SalesCrMemoHeader.SystemId;
                end;

                if not IsNullGuid(DigitalNotifEntry."Source Document Id") then
                    DigitalNotifEntry.Modify();
            until DigitalNotifEntry.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeSourceDocumentIdOnDigitalNotifEntries'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG Digital Notif. Entr.");
    end;
}
#endif
