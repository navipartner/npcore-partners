codeunit 6150945 "NPR UPG POS SalesWorkflowStep"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnUpgradePerCompany()
    begin
        ShowReturnAmountDialog();
        AddNewOnSaleCoupons();
        UpdateDisplayOnSaleLineInsert();
        PrintWarrantyAfterSaleLine();
        UpdateTicketOnSaleLineInsert();
        UpdateMembershipOnSaleLineInsert();
        MCSSaleLineUpload();
    end;

    local procedure ShowReturnAmountDialog()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS SalesWorkflowStep', 'ShowReturnAmountDialog');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ShowReturnAmountDialog')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeShowReturnAmountDialog();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ShowReturnAmountDialog'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeShowReturnAmountDialog()
    var
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        POSSalesWorkflowStep.SetRange("Subscriber Function", 'ShowReturnAmountDialog');
        POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", 6150855);
        POSSalesWorkflowStep.Setrange("Workflow Code", 'FINISH_SALE');
        if POSSalesWorkflowStep.FindSet() then
            POSSalesWorkflowStep.DeleteAll();
    end;

    local procedure DeletePOSWorkflowStepAfterInsertLine(SubscriberFunction: Text)
    var
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        POSSalesWorkflowStep.Reset();
        POSSalesWorkflowStep.SetRange("Workflow Code", 'AFTER_INSERT_LINE');
        POSSalesWorkflowStep.SetRange("Subscriber Function", SubscriberFunction);
        if POSSalesWorkflowStep.FindSet() then
            POSSalesWorkflowStep.DeleteAll();
    end;

    local procedure AddNewOnSaleCoupons()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'AddNewOnSaleCoupons');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'AddNewOnSaleCoupons')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DeletePOSWorkflowStepAfterInsertLine('AddNewOnSaleCoupons');

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'AddNewOnSaleCoupons'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateDisplayOnSaleLineInsert()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'UpdateDisplayOnSaleLineInsert');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateDisplayOnSaleLineInsert')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DeletePOSWorkflowStepAfterInsertLine('UpdateDisplayOnSaleLineInsert');

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateDisplayOnSaleLineInsert'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure PrintWarrantyAfterSaleLine()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'PrintWarrantyAfterSaleLine');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'PrintWarrantyAfterSaleLine')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DeletePOSWorkflowStepAfterInsertLine('PrintWarrantyAfterSaleLine');

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'PrintWarrantyAfterSaleLine'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateTicketOnSaleLineInsert()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'UpdateTicketOnSaleLineInsert');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateTicketOnSaleLineInsert')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DeletePOSWorkflowStepAfterInsertLine('UpdateTicketOnSaleLineInsert');

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateTicketOnSaleLineInsert'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateMembershipOnSaleLineInsert()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'UpdateMembershipOnSaleLineInsert');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateMembershipOnSaleLineInsert')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DeletePOSWorkflowStepAfterInsertLine('UpdateMembershipOnSaleLineInsert');

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateMembershipOnSaleLineInsert'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure MCSSaleLineUpload()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'MCSSaleLineUpload');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'MCSSaleLineUpload')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DeletePOSWorkflowStepAfterInsertLine('MCSSaleLineUpload');

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'MCSSaleLineUpload'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POS SalesWorkflowStep");
    end;
}