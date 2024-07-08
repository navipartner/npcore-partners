codeunit 6184764 "NPR UPG POSMenu Actions v3"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnUpgradePerCompany()
    begin
        UpgradePOSMenu_MMMembermgmt();
        UpgradePOSMenu_MMMembermgmt_1();
        UpgradePOSMenu_MMMembermgmt2();
        UpgradePOSMenu_MMMembermgmt2_1();
        UpgradePOSMenu_ScanVoucher();
        UpgradePOSMenu_IssueReturnVoucher();
        UpgradePOSMenu_PayinPayout();
        UpgradePOSMenu_TMTicketMgmt();
        UpgradePOSMenu_TMTicketMgmt2();
        UpgradePOSMenu_TMTicketMgmt_1();
        UpgradePOSMenu_TMTicketMgmt2_1();
        UpgradeOSMenuButtonParameterActionCodes();

    end;

    local procedure UpgradePOSMenu_MMMembermgmt()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSMenu Actions v3', 'MM_MEMBERMGT');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'MM_MEMBERMGT')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'MM_MEMBERMGT');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::MM_MEMBERMGMT_WF3);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'MM_MEMBERMGT'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSMenu_MMMembermgmt_1()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSMenu Actions v3', 'MM_MEMBERMGT-1');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'MM_MEMBERMGT-1')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'MM_MEMBERMGT');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::MM_MEMBERMGMT_WF3);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'MM_MEMBERMGT-1'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSMenu_MMMembermgmt2()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSMenu Actions v3', 'MM_MEMBERMGMT_WF2');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'MM_MEMBERMGMT_WF2')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'MM_MEMBERMGMT_WF2');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::MM_MEMBERMGMT_WF3);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'MM_MEMBERMGMT_WF2'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSMenu_MMMembermgmt2_1()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSMenu Actions v3', 'MM_MEMBERMGMT_WF2-1');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'MM_MEMBERMGMT_WF2-1')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'MM_MEMBERMGMT_WF2');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::MM_MEMBERMGMT_WF3);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'MM_MEMBERMGMT_WF2-1'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSMenu_ScanVoucher()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSMenu Actions v3', 'SCAN_VOUCHER');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SCAN_VOUCHER')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'SCAN_VOUCHER');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::SCAN_VOUCHER_2);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SCAN_VOUCHER'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSMenu_IssueReturnVoucher()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSMenu Actions v3', 'ISSUE_RETURN_VOUCHER');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ISSUE_RETURN_VOUCHER')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'ISSUE_RETURN_VOUCHER');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::ISSUE_RETURN_VCHR_2);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ISSUE_RETURN_VOUCHER'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSMenu_PayinPayout()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSMenuButton: Record "NPR POS Menu Button";
        POSActionParameter: Record "NPR POS Parameter Value";
        POSActionParameter2: Record "NPR POS Parameter Value";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSMenu Actions v3', 'PAYIN_PAYOUT');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'PAYIN_PAYOUT')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'PAYIN_PAYOUT');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::PAYMENT_PAYIN_PAYOUT);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;

        POSActionParameter.SetRange("Table No.", Database::"NPR POS Menu Button");
        POSActionParameter.SetRange("Action Code", 'PAYIN_PAYOUT');
        POSActionParameter.SetRange(Name, 'Pay Option');
        if POSActionParameter.FindSet() then
            repeat
                if POSActionParameter2.get(POSActionParameter."Table No.", POSActionParameter.Code, POSActionParameter.ID, POSActionParameter."Record ID", 'PayOption') then begin
                    if POSActionParameter.Value = 'Payout' then
                        POSActionParameter2.Value := 'PayOut'
                    else
                        POSActionParameter2.Value := POSActionParameter.Value;
                    POSActionParameter2.Modify(true);
                    POSActionParameter.Delete();
                end;
            until POSActionParameter.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'PAYIN_PAYOUT'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSMenu_TMTicketMgmt()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSMenu Actions v3', 'TM_TICKETMGMT');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'TM_TICKETMGMT')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'TM_TICKETMGMT');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::TM_TICKETMGMT_3);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'TM_TICKETMGMT'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSMenu_TMTicketMgmt2()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSMenu Actions v3', 'TM_TICKETMGMT_2');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'TM_TICKETMGMT_2')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'TM_TICKETMGMT_2');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::TM_TICKETMGMT_3);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'TM_TICKETMGMT_2'));
        LogMessageStopwatch.LogFinish();
    end;


    local procedure UpgradePOSMenu_TMTicketMgmt_1()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSMenu Actions v3', 'TM_TICKETMGMT-1');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'TM_TICKETMGMT-1')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'TM_TICKETMGMT');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::TM_TICKETMGMT_3);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'TM_TICKETMGMT-1'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSMenu_TMTicketMgmt2_1()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSMenu Actions v3', 'TM_TICKETMGMT_2-1');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'TM_TICKETMGMT_2-1')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'TM_TICKETMGMT_2');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::TM_TICKETMGMT_3);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'TM_TICKETMGMT_2-1'));
        LogMessageStopwatch.LogFinish();
    end;


    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POSMenu Actions v3");
    end;

    local procedure UpgradeOSMenuButtonParameterActionCodes()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSMenu Actions v3', 'UpgradeOSMenuButtonParameterActionCodes');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeOSMenuButtonParameterActionCodes')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdatePOSMenuButtonParameterActionCodes();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeOSMenuButtonParameterActionCodes'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdatePOSMenuButtonParameterActionCodes()
    var
        POSMenuButton: Record "NPR POS Menu Button";
        POSParameterValue: Record "NPR POS Parameter Value";
    begin
        POSMenuButton.Reset();
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetFilter("Action Code", '<>%1', '');
        POSMenuButton.SetLoadFields("Action Type", "Action Code", "Menu Code", ID);
        if POSMenuButton.FindSet(false) then
            repeat
                POSParameterValue.Reset();
                POSParameterValue.SetRange("Table No.", Database::"NPR POS Menu Button");
                POSParameterValue.SetRange(Code, POSMenuButton."Menu Code");
                POSParameterValue.SetRange("Record ID", POSMenuButton.RecordId);
                POSParameterValue.SetRange(ID, POSMenuButton.ID);
                POSParameterValue.SetFilter("Action Code", '<>%1', POSMenuButton."Action Code");
                if not POSParameterValue.IsEmpty then
                    POSParameterValue.ModifyAll("Action Code", POSMenuButton."Action Code");
            until POSMenuButton.Next() = 0;
    end;
}