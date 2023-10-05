codeunit 6150945 "NPR UPG POS Scenarios"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnUpgradePerCompany()
    begin
        //FINISH_SALE scenario
        ShowReturnAmountDialog();

        //AFTER_LOGIN scenario
        SelectMemberOnAfterLogin();
        SelectCustomerOnAfterLogin();

        //AFTER_INSERT_LINE scenario 
        AddNewOnSaleCoupons();
        UpdateDisplayOnSaleLineInsert();
        PrintWarrantyAfterSaleLine();
        UpdateTicketOnSaleLineInsert();
        UpdateMembershipOnSaleLineInsert();
        MCSSaleLineUpload();

        //PAYMENT_VIEW scenario
        PopupDimension();
    end;

    local procedure ShowReturnAmountDialog()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'ShowReturnAmountDialog');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ShowReturnAmountDialog')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeShowReturnAmountDialog();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ShowReturnAmountDialog'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure SelectMemberOnAfterLogin()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'SelectMemberOnAfterLogin');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SelectMemberOnAfterLogin')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        if not POSSaleWorkflowEnabled(Codeunit::"NPR MM POS Action: MemberMgmt.", 'OnAfterLogin_SelectMemberRequired') then
            CheckPOSUnitReq('OnAfterLogin_SelectMemberRequired');

        DeletePOSWorkflowStepAfterLogin(POSSalesWorkflowStep."Subscriber Codeunit ID", 'OnAfterLogin_SelectMemberRequired');

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SelectMemberOnAfterLogin'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeShowReturnAmountDialog()
    begin
        DeletePOSWorkflowStepFinishSale(6150855, 'ShowReturnAmountDialog');
    end;

    local procedure DeletePOSWorkflowStepAfterLogin(SubscriberCodeunitID: Integer; SubscriberFunction: Text[80])
    begin
        DeletePOSWorkflowStep('AFTER_LOGIN', SubscriberCodeunitID, SubscriberFunction);
    end;

    local procedure DeletePOSWorkflowStepAfterInsertLine(SubscriberFunction: Text[80])
    begin
        DeletePOSWorkflowStep('AFTER_INSERT_LINE', 0, SubscriberFunction);
    end;

    local procedure DeletePOSWorkflowStepFinishSale(SubscriberCodeunitID: Integer; SubscriberFunction: Text[80])
    begin
        DeletePOSWorkflowStep('FINISH_SALE', SubscriberCodeunitID, SubscriberFunction);
    end;

    local procedure DeletePOSWorkflowStepPaymentView(SubscriberCodeunitID: Integer; SubscriberFunction: Text[80])
    begin
        DeletePOSWorkflowStep('PAYMENT_VIEW', SubscriberCodeunitID, SubscriberFunction);
    end;

    local procedure DeletePOSWorkflowStep(WorkflowCode: Code[20]; SubscriberCodeunitID: Integer; SubscriberFunction: Text[80])
    var
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        POSSalesWorkflowStep.Reset();
        POSSalesWorkflowStep.SetRange("Workflow Code", WorkflowCode);
        if SubscriberCodeunitID <> 0 then
            POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", SubscriberCodeunitID);
        POSSalesWorkflowStep.SetRange("Subscriber Function", SubscriberFunction);
        if not POSSalesWorkflowStep.IsEmpty() then
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

    local procedure PopupDimension()
    var
        POSPaymentViewEventSetup: Record "NPR POS Paym. View Event Setup";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'PopupDimension');

        if not UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'PopupDimension')) then begin
            if POSPaymentViewEventSetup.Get() then begin
                POSSalesWorkflowStep.SetRange("Workflow Code", 'PAYMENT_VIEW');
                POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", Codeunit::"NPR POS Paym. View Event Mgt.");  //CU 6151053
                POSSalesWorkflowStep.SetRange("Subscriber Function", 'PopupDimension');
                POSSalesWorkflowStep.SetRange(Enabled, true);
                POSPaymentViewEventSetup."Dimension Popup Enabled" := not POSSalesWorkflowStep.IsEmpty();
                POSPaymentViewEventSetup."Skip Popup on Dimension Value" := true;  //Show popup only on first payment
                POSPaymentViewEventSetup.Modify();
            end;
            DeletePOSWorkflowStepPaymentView(Codeunit::"NPR POS Paym. View Event Mgt.", 'PopupDimension');
            UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'PopupDimension'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POS Scenarios");
    end;

    local procedure SelectCustomerOnAfterLogin()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'SelectCustomerOnAfterLogin');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SelectCustomerOnAfterLogin')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        if not POSSaleWorkflowEnabled(Codeunit::"NPR POSAction: Ins. Customer", 'SelectCustomerRequired') then
            CheckPOSUnitReq('SelectCustomerRequired');

        DeletePOSWorkflowStepAfterLogin(POSSalesWorkflowStep."Subscriber Codeunit ID", 'SelectCustomerRequired');

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SelectCustomerOnAfterLogin'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure CreatePOSFunctionality(var POSFunctionality: Record "NPR POS Functionality Profile")
    begin
        if not POSFunctionality.Get('DEFAULT') then begin
            POSFunctionality.Init();
            POSFunctionality.Code := 'DEFAULT';
            POSFunctionality.Description := 'Default Profile';
            POSFunctionality.Insert();
        end;
    end;

    local procedure POSSaleWorkflowEnabled(SubscriberID: Integer; SubscriberFunction: Text) ScenarioEnabled: Boolean
    var
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSUnit: Record "NPR POS Unit";
        POSFunctionality: Record "NPR POS Functionality Profile";
    begin
        POSSalesWorkflowStep.SetRange("Workflow Code", 'AFTER_LOGIN');
        POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", SubscriberID);
        POSSalesWorkflowStep.SetRange("Subscriber Function", SubscriberFunction);
        if POSSalesWorkflowStep.FindFirst() then
            if POSSalesWorkflowStep.Enabled then begin
                ScenarioEnabled := true;
                CreatePOSFunctionality(POSFunctionality);
                if SubscriberFunction = 'SelectCustomerRequired' then
                    POSFunctionality."Require Select Customer" := true;
                if SubscriberFunction = 'OnAfterLogin_SelectMemberRequired' then
                    POSFunctionality."Require Select Member" := true;
                POSFunctionality.Modify();
                POSUnit.SetFilter("POS Functionality Profile", '<>%1', POSFunctionality.Code);
                if POSUnit.FindSet() then
                    POSUnit.ModifyAll("POS Functionality Profile", POSFunctionality.Code);
            end;
    end;

    local procedure CheckPOSUnitReq(SubscriberFunction: Text)
    var
        POSUnit: Record "NPR POS Unit";
        POSFunctionality: Record "NPR POS Functionality Profile";
    begin

        if SubscriberFunction = 'SelectCustomerRequired' then
            POSUnit.SetRange("Require Select Customer", true);
        if SubscriberFunction = 'OnAfterLogin_SelectMemberRequired' then
            POSUnit.SetRange("Require Select Member", true);

        if POSUnit.FindSet() then begin
            CreatePOSFunctionality(POSFunctionality);
            if SubscriberFunction = 'SelectCustomerRequired' then
                POSFunctionality."Require Select Customer" := true;
            if SubscriberFunction = 'OnAfterLogin_SelectMemberRequired' then
                POSFunctionality."Require Select Member" := true;
            POSFunctionality.Modify();
            POSUnit.ModifyAll("POS Functionality Profile", POSFunctionality.Code);
        end;
    end;

}