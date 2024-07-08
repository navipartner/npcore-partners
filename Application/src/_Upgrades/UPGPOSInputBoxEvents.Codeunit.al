codeunit 6060077 "NPR UPG POS Input Box Events"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeTicketArrivalActionCode();
    end;

    local procedure UpgradeTicketArrivalActionCode()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Input Box Events', 'UpgradeTicketArrivalActionCode');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeTicketArrivalActionCode')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdateTicketArrivalTicketMgtActionCode();
        UpdateTicketArrivalActionCodeOnEanBoxSetupEvent();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeTicketArrivalActionCode'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateTicketArrivalTicketMgtActionCode()
    var
        EanBoxEvent: Record "NPR Ean Box Event";
        TicketArrivalCodeLbl: Label 'TICKET_ARRIVAL', Locked = true;
        TicketMgtActionCodeLbl: Label 'TM_TICKETMGMT_3', Locked = true;
    begin
        if not EanBoxEvent.Get(TicketArrivalCodeLbl) then
            exit;
        if EanBoxEvent."Action Code" = TicketMgtActionCodeLbl then
            exit;
        EanBoxEvent."Action Code" := TicketMgtActionCodeLbl;
        EanBoxEvent.Modify();
    end;

    local procedure UpdateTicketArrivalActionCodeOnEanBoxSetupEvent()
    var
        EanBoxEventSetup: Record "NPR Ean Box Setup Event";
        SetupCode: Label 'SALE', Locked = true;
        TicketArrivalCodeLbl: Label 'TICKET_ARRIVAL', Locked = true;
        TicketMgtActionCodeLbl: Label 'TM_TICKETMGMT_3', Locked = true;
    begin
        if not EanBoxEventSetup.Get(SetupCode, TicketArrivalCodeLbl) then
            exit;
        if EanBoxEventSetup."Action Code" = TicketMgtActionCodeLbl then
            exit;
        EanBoxEventSetup."Action Code" := TicketMgtActionCodeLbl;
        EanBoxEventSetup.Modify();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POS Input Box Events");
    end;
}
