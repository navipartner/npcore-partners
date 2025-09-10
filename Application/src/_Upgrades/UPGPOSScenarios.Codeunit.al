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
        PrintCreditVoucherOnSale();
        EmailReceiptOnSale();
        UpgradeAuditProfile();
        DeliverCollectDocument();
        UpgradeMemberProfile();
        UpgradeLoyaltyProfile();
        UpgradeTicketProfile();
        DeleteFinishSaleWorkflowSteps();

        //AFTER_LOGIN scenario
        SelectRequiredParam();

        //AFTER_INSERT_LINE scenario 
        AddNewOnSaleCoupons();
        UpdateDisplayOnSaleLineInsert();
        PrintWarrantyAfterSaleLine();
        UpdateTicketOnSaleLineInsert();
        UpdateMembershipOnSaleLineInsert();
        MCSSaleLineUpload();

        //PAYMENT_VIEW scenario
        PopupDimension();
        TestItemInventory();

        //FINISH_CREDIT_SALE scenario
        DimPopupEvery();
        EjectPaymentBinOnCreditSale();
        DeleteFinishCreditSaleWorkflowSteps();

    end;

    local procedure EjectPaymentBinOnCreditSale()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'EjectPaymentBinOnCreditSale');

        if not UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'EjectPaymentBinOnCreditSale')) then begin
            POSSalesWorkflowStep.SetRange("Workflow Code", 'FINISH_CREDIT_SALE');
            POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", Codeunit::"NPR POS Payment Bin Eject Mgt.");
            POSSalesWorkflowStep.SetRange("Subscriber Function", 'EjectPaymentBinOnCreditSale');
            POSSalesWorkflowStep.SetRange(Enabled, true);
            if not POSSalesWorkflowStep.IsEmpty() then
                if not POSAuditProfile.IsEmpty() then
                    POSAuditProfile.ModifyAll("Bin Eject After Credit Sale", true);

            UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'EjectPaymentBinOnCreditSale'));
        end;
    end;

    local procedure DeleteFinishSaleWorkflowSteps()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'DeleteFinishSaleWorkflowSteps');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'DeleteFinishSaleWorkflowSteps')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DeletePOSWorkflowStepFinishSale(Codeunit::"NPR CleanCash Wrapper", 'CreateCleanCashOnSale');
        DeletePOSWorkflowStepFinishSale(Codeunit::"NPR POS Payment Bin Eject Mgt.", 'EjectPaymentBin');
        DeletePOSWorkflowStepFinishSale(Codeunit::"NPR POS Sales Print Mgt.", 'PrintReceiptOnSale');
        DeletePOSWorkflowStepFinishSale(Codeunit::"NPR MM Loyalty Point Mgt.", 'PointAssignmentOnSale');
        DeletePOSWorkflowStepFinishSale(Codeunit::"NPR Tax Free Handler Mgt.", 'IssueTaxFreeVoucherOnSale');
        DeletePOSWorkflowStepFinishSale(Codeunit::"NPR E-mail Doc. Mgt.", 'EmailReceiptOnSale');
        DeletePOSWorkflowStepFinishSale(Codeunit::"NPR MM Member Retail Integr.", 'PrintMembershipsOnSale');
        DeletePOSWorkflowStepFinishSale(Codeunit::"NPR MM Member Notification", 'SendMemberNotificationOnSales');
        DeletePOSWorkflowStepFinishSale(Codeunit::"NPR TM Ticket Management", 'PrintTicketsOnSale');
        DeletePOSWorkflowStepFinishSale(Codeunit::"NPR NpCs POSSession Mgt.", 'DeliverCollectDocument');

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'DeleteFinishSaleWorkflowSteps'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure DeleteFinishCreditSaleWorkflowSteps()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'DeleteFinishCreditSaleWorkflowSteps');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'DeleteFinishCreditSaleWorkflowSteps')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DeletePOSWorkflowStepFinishCreditSale(Codeunit::"NPR POS Payment Bin Eject Mgt.", 'EjectPaymentBinOnCreditSale');

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'DeleteFinishCreditSaleWorkflowSteps'));
        LogMessageStopwatch.LogFinish();
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

    local procedure DeletePOSWorkflowStepFinishCreditSale(SubscriberCodeunitID: Integer; SubscriberFunction: Text[80])
    begin
        DeletePOSWorkflowStep('FINISH_CREDIT_SALE', SubscriberCodeunitID, SubscriberFunction);
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

    local procedure TestItemInventory()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'TestItemInventory');

        if not UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'TestItemInventory')) then begin
            POSSalesWorkflowStep.SetRange("Workflow Code", 'PAYMENT_VIEW');
            POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", Codeunit::"NPR POS View Change WF Mgt.");
            POSSalesWorkflowStep.SetRange("Subscriber Function", 'TestItemInventory');
            POSSalesWorkflowStep.SetRange(Enabled, true);
            if not POSSalesWorkflowStep.IsEmpty() then
                if not POSAuditProfile.IsEmpty() then
                    POSAuditProfile.ModifyAll("Test Item Inventory", true);

            UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'TestItemInventory'));
        end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POS Scenarios");
    end;

    local procedure SelectRequiredParam()
    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
        POSSetup: Record "NPR POS Setup";
        LoginActionRefreshNeeded: Boolean;
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSAction: Record "NPR POS Action";
        POSRefreshWorkflows: Codeunit "NPR POS Refresh Workflows";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'SelectionReqParam');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SelectionReqParam')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        POSSetup.Reset();
        if not POSSetup.FindSet(false) then
            exit;
        repeat
            if POSAction.get(POSSetup."Login Action Code") then begin
                if POSAction."Workflow Implementation" <> POSAction."Workflow Implementation"::LEGACY then begin
                    POSRefreshWorkflows.RefreshSpecific(POSAction."Workflow Implementation".AsInteger());
                    LoginActionRefreshNeeded := ParamMgt.RefreshParametersRequired(POSSetup.RecordId, '', POSSetup.FieldNo("Login Action Code"), POSSetup."Login Action Code");
                    if LoginActionRefreshNeeded then
                        ParamMgt.RefreshParameters(POSSetup.RecordId, '', POSSetup.FieldNo("Login Action Code"), POSSetup."Login Action Code");

                    UpdateParam(Codeunit::"NPR MM POS Action: MemberMgmt.", 'OnAfterLogin_SelectMemberRequired', POSSetup);
                    DeletePOSWorkflowStepAfterLogin(Codeunit::"NPR MM POS Action: MemberMgmt.", 'OnAfterLogin_SelectMemberRequired');

                    UpdateParam(Codeunit::"NPR POSAction: Ins. Customer", 'SelectCustomerRequired', POSSetup);
                    DeletePOSWorkflowStepAfterLogin(Codeunit::"NPR POSAction: Ins. Customer", 'SelectCustomerRequired');
                end;
            end;
        until POSSetup.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SelectionReqParam'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateParam(SubscriberID: Integer; SubscriberFunction: Text; POSSetup: Record "NPR POS Setup")
    var
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSUnit: Record "NPR POS Unit";
        POSFuncPRofile: Record "NPR POS Functionality Profile";
        ParamValue: Record "NPR POS Parameter Value";
        Enabled: Boolean;
    begin
        Enabled := false;
        POSSalesWorkflowStep.SetRange("Workflow Code", 'AFTER_LOGIN');
        POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", SubscriberID);
        POSSalesWorkflowStep.SetRange("Subscriber Function", SubscriberFunction);
        POSSalesWorkflowStep.SetRange(Enabled, true);
        if POSSalesWorkflowStep.FindFirst() then
            if POSSalesWorkflowStep.Enabled then
                Enabled := true;

        if SubscriberFunction = 'SelectCustomerRequired' then
            POSUnit.SetRange("Require Select Customer", true);
        if SubscriberFunction = 'OnAfterLogin_SelectMemberRequired' then
            POSUnit.SetRange("Require Select Member", true);
        if not POSUnit.IsEmpty() then
            Enabled := true;

        POSUnit.Reset();
        POSUnit.SetFilter("POS Functionality Profile", '<>%1', '');
        POSUnit.SetRange("POS Named Actions Profile", POSSetup."Primary Key");
        if POSUnit.FindSet(false) then
            repeat
                if POSFuncPRofile.Get(POSUnit."POS Functionality Profile") then begin
                    if SubscriberFunction = 'OnAfterLogin_SelectMemberRequired' then
                        if POSFuncPRofile."Require Select Member" then
                            Enabled := true;
                end;
                if POSFuncPRofile.Get(POSUnit."POS Functionality Profile") then begin
                    if SubscriberFunction = 'SelectCustomerRequired' then
                        if POSFuncPRofile."Require Select Customer" then
                            Enabled := true;
                end;
            until POSUnit.Next() = 0;

        if Enabled then begin
            ParamValue.SetRange("Table No.", Database::"NPR POS Setup");
            ParamValue.SetRange(Code, '');
            ParamValue.SetRange("Record ID", POSSetup.RecordId);
            ParamValue.SetRange("Action Code", 'LOGIN');
            if SubscriberFunction = 'OnAfterLogin_SelectMemberRequired' then
                ParamValue.SetRange(Name, 'SelectMemberReq');
            if SubscriberFunction = 'SelectCustomerRequired' then
                ParamValue.SetRange(Name, 'SelectCustReq');

            if ParamValue.FindSet() then
                ParamValue.ModifyAll(Value, 'true');
        end;
    end;

    local procedure PrintCreditVoucherOnSale()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'PrintCreditVoucherOnSale');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'PrintCreditVoucherOnSale')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DeletePOSWorkflowStepFinishSale(Codeunit::"NPR POS Sales Print Mgt.", 'PrintCreditVoucherOnSale');

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'PrintCreditVoucherOnSale'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure EmailReceiptOnSale()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        POSReceiptProfile: Record "NPR POS Receipt Profile";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSUnit: Record "NPR POS Unit";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'EmailReceiptOnSale');
        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'EmailReceiptOnSale')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        POSSalesWorkflowStep.SetRange("Workflow Code", 'FINISH_SALE');
        POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", Codeunit::"NPR E-mail Doc. Mgt.");
        POSSalesWorkflowStep.SetRange("Subscriber Function", 'EmailReceiptOnSale');
        POSSalesWorkflowStep.SetRange(Enabled, true);
        If POSSalesWorkflowStep.FindSet(false) then
            repeat
                POSUnit.SetFilter("POS Sales Workflow Set", POSSalesWorkflowStep."Set Code");
                if POSUnit.FindSet(false) then
                    repeat
                        POSReceiptProfile.SetFilter(Code, POSUnit."POS Receipt Profile");
                        if POSReceiptProfile.FindFirst() then
                            if not POSReceiptProfile."E-mail Receipt On Sale" then begin
                                POSReceiptProfile."E-mail Receipt On Sale" := true;
                                POSReceiptProfile.Modify();
                            end;
                    until POSUnit.Next() = 0;
            until POSSalesWorkflowStep.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'EmailReceiptOnSale'));
        LogMessageStopwatch.LogFinish();

    end;

    local procedure UpgradeAuditProfile()
    var
        POSScenarioUpgradeBuff: Record "NPR POS Scenario Upgrade Buff";
        AuditProfileUpgradeBuff: Record "NPR Audit Profile Upgrade Buff";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'UpgradeAuditProfile');
        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeAuditProfile')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        CreateAuditProfilePOSScenarioUpgradeBuffer(POSScenarioUpgradeBuff);
        CreateAuditProfileUpgradeBuff(POSScenarioUpgradeBuff, AuditProfileUpgradeBuff);
        ProcessAuditProfileUpgradeBuff(AuditProfileUpgradeBuff);

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeAuditProfile'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeMemberProfile()
    var
        POSScenarioUpgradeBuff: Record "NPR POS Scenario Upgrade Buff";
        NPRMemberProfileUpgBuff: Record "NPR Member Profile Upg Buff";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'UpgradeMemberProfile');
        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeMemberProfile')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        CreateMemberProfilePOSScenarioUpgradeBuffer(POSScenarioUpgradeBuff);
        CreateMemberProfileUpgradeBuff(POSScenarioUpgradeBuff, NPRMemberProfileUpgBuff);
        ProcessMemberProfileUpgradeBuff(NPRMemberProfileUpgBuff);

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeMemberProfile'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure CreateMemberProfileUpgradeBuff(var POSScenarioUpgradeBuff: Record "NPR POS Scenario Upgrade Buff"; var NPRMemberProfileUpgBuff: Record "NPR Member Profile Upg Buff")
    var
        POSUnit: Record "NPR POS Unit";
        POSMemberProfile: Record "NPR MM POS Member Profile";
        NewPOSMemberProfile: Record "NPR MM POS Member Profile";
    begin
        POSScenarioUpgradeBuff.Reset();
        if not POSScenarioUpgradeBuff.FindSet() then
            exit;

        repeat
            POSUnit.Reset();
            POSUnit.SetRange("POS Sales Workflow Set", POSScenarioUpgradeBuff.Code);
            POSUnit.SetLoadFields("No.", "POS Sales Workflow Set", "POS Member Profile");
            if POSUnit.FindSet() then
                repeat
                    POSMemberProfile.Reset();
                    POSMemberProfile.SetRange("Print Membership On Sale", POSScenarioUpgradeBuff."Print Membership On Sale");
                    POSMemberProfile.SetRange("Send Notification On Sale", POSScenarioUpgradeBuff."Send Notification On Sale");
                    POSMemberProfile.SetRange(Code, POSUnit."POS Member Profile");
                    if POSMemberProfile.IsEmpty then
                        if not NPRMemberProfileUpgBuff.Get(POSUnit."POS Sales Workflow Set", POSUnit."POS Member Profile") then begin
                            NewPOSMemberProfile.Init();
                            NewPOSMemberProfile.Code := GetPOSMemberProfileUpgradeCode();
                            NewPOSMemberProfile."Print Membership On Sale" := POSScenarioUpgradeBuff."Print Membership On Sale";
                            NewPOSMemberProfile."Send Notification On Sale" := POSScenarioUpgradeBuff."Send Notification On Sale";
                            NewPOSMemberProfile.Insert();

                            NPRMemberProfileUpgBuff.Init();
                            NPRMemberProfileUpgBuff."POS New Member Profile Code" := NewPOSMemberProfile.Code;
                            NPRMemberProfileUpgBuff."POS Member Profile Code" := POSUnit."POS Member Profile";
                            NPRMemberProfileUpgBuff."Workflow Set Code" := POSScenarioUpgradeBuff.Code;
                            NPRMemberProfileUpgBuff.Insert();
                        end;
                until POSUnit.Next() = 0;
        until POSScenarioUpgradeBuff.Next() = 0;

    end;

    local procedure ProcessMemberProfileUpgradeBuff(var NPRMemberProfileUpgBuff: Record "NPR Member Profile Upg Buff")
    var
        POSUnit: Record "NPR POS Unit";
    begin
        NPRMemberProfileUpgBuff.Reset();
        if not NPRMemberProfileUpgBuff.FindSet() then
            exit;

        repeat
            POSUnit.Reset();
            POSUnit.SetRange("POS Member Profile", NPRMemberProfileUpgBuff."POS Member Profile Code");
            POSUnit.SetRange("POS Sales Workflow Set", NPRMemberProfileUpgBuff."Workflow Set Code");
            if not POSUnit.IsEmpty then
                POSUnit.ModifyAll("POS Member Profile", NPRMemberProfileUpgBuff."POS New Member Profile Code");
        until NPRMemberProfileUpgBuff.Next() = 0;
    end;

    local procedure CreateMemberProfilePOSScenarioUpgradeBuffer(var POSScenarioUpgradeBuff: Record "NPR POS Scenario Upgrade Buff")
    var
        POSUnit: Record "NPR POS Unit";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSSalesWFSetEntry: Record "NPR POS Sales WF Set Entry";
    begin
        POSScenarioUpgradeBuff.Reset();
        if not POSScenarioUpgradeBuff.IsEmpty then
            POSScenarioUpgradeBuff.DeleteAll();

        POSUnit.Reset();
        POSUnit.SetCurrentKey("POS Sales Workflow Set");
        POSUnit.SetLoadFields("No.", "POS Sales Workflow Set");
        if not POSUnit.FindSet() then
            exit;

        repeat
            if not POSScenarioUpgradeBuff.Get(POSUnit."POS Sales Workflow Set") then begin
                POSScenarioUpgradeBuff.Init();
                POSScenarioUpgradeBuff.Code := POSUnit."POS Sales Workflow Set";
                POSScenarioUpgradeBuff.Insert();
            end;

            POSSalesWorkflowStep.Reset();
            POSSalesWorkflowStep.SetRange("Workflow Code", 'FINISH_SALE');
            POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", CODEUNIT::"NPR MM Member Retail Integr.");
            POSSalesWorkflowStep.SetRange("Subscriber Function", 'PrintMembershipsOnSale');
            POSSalesWorkflowStep.SetRange("Set Code", '');
            if (POSScenarioUpgradeBuff.Code <> '') and POSSalesWFSetEntry.Get(POSScenarioUpgradeBuff.Code, 'FINISH_SALE') then
                POSSalesWorkflowStep.SetRange("Set Code", POSScenarioUpgradeBuff.Code);
            POSSalesWorkflowStep.SetLoadFields("Workflow Code", "Subscriber Codeunit ID", "Subscriber Function", Enabled, "Set Code");
            if not POSSalesWorkflowStep.FindFirst() then
                POSScenarioUpgradeBuff."Print Membership On Sale" := false
            else
                POSScenarioUpgradeBuff."Print Membership On Sale" := POSSalesWorkflowStep.Enabled;

            POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", CODEUNIT::"NPR MM Member Notification");
            POSSalesWorkflowStep.SetRange("Subscriber Function", 'SendMemberNotificationOnSales');
            if not POSSalesWorkflowStep.FindFirst() then
                POSScenarioUpgradeBuff."Send Notification On Sale" := false
            else
                POSScenarioUpgradeBuff."Send Notification On Sale" := POSSalesWorkflowStep.Enabled;

            POSScenarioUpgradeBuff.Modify();

            POSUnit.SetRange("POS Sales Workflow Set", POSUnit."POS Sales Workflow Set");
            POSUnit.FindLast();
            POSUnit.SetRange("POS Sales Workflow Set");
        until POSUnit.Next() = 0;
    end;

    local procedure CreateAuditProfilePOSScenarioUpgradeBuffer(var POSScenarioUpgradeBuff: Record "NPR POS Scenario Upgrade Buff")
    var
        POSUnit: Record "NPR POS Unit";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSSalesWFSetEntry: Record "NPR POS Sales WF Set Entry";
    begin
        POSScenarioUpgradeBuff.Reset();
        if not POSScenarioUpgradeBuff.IsEmpty then
            POSScenarioUpgradeBuff.DeleteAll();

        POSUnit.Reset();
        POSUnit.SetCurrentKey("POS Sales Workflow Set");
        POSUnit.SetLoadFields("No.", "POS Sales Workflow Set");
        if not POSUnit.FindSet() then
            exit;

        repeat
            if not POSScenarioUpgradeBuff.Get(POSUnit."POS Sales Workflow Set") then begin
                POSScenarioUpgradeBuff.Init();
                POSScenarioUpgradeBuff.Code := POSUnit."POS Sales Workflow Set";
                POSScenarioUpgradeBuff.Insert();
            end;

            POSSalesWorkflowStep.Reset();
            POSSalesWorkflowStep.SetRange("Workflow Code", 'FINISH_SALE');
            POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", CODEUNIT::"NPR POS Sales Print Mgt.");
            POSSalesWorkflowStep.SetRange("Subscriber Function", 'PrintReceiptOnSale');
            POSSalesWorkflowStep.SetRange("Set Code", '');
            if (POSScenarioUpgradeBuff.Code <> '') and POSSalesWFSetEntry.Get(POSScenarioUpgradeBuff.Code, 'FINISH_SALE') then
                POSSalesWorkflowStep.SetRange("Set Code", POSScenarioUpgradeBuff.Code);
            POSSalesWorkflowStep.SetLoadFields("Workflow Code", "Subscriber Codeunit ID", "Subscriber Function", Enabled, "Set Code");
            if not POSSalesWorkflowStep.FindFirst() then
                POSScenarioUpgradeBuff."Do Not Print Receipt on Sale" := true
            else
                POSScenarioUpgradeBuff."Do Not Print Receipt on Sale" := not POSSalesWorkflowStep.Enabled;


            POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", CODEUNIT::"NPR POS Payment Bin Eject Mgt.");
            POSSalesWorkflowStep.SetRange("Subscriber Function", 'EjectPaymentBin');
            if not POSSalesWorkflowStep.FindFirst() then
                POSScenarioUpgradeBuff."Bin Eject After Sale" := false
            else
                POSScenarioUpgradeBuff."Bin Eject After Sale" := POSSalesWorkflowStep.Enabled;

            POSScenarioUpgradeBuff.Modify();

            POSUnit.SetRange("POS Sales Workflow Set", POSUnit."POS Sales Workflow Set");
            POSUnit.FindLast();
            POSUnit.SetRange("POS Sales Workflow Set");
        until POSUnit.Next() = 0;
    end;

    local procedure CreateAuditProfileUpgradeBuff(var POSScenarioUpgradeBuff: Record "NPR POS Scenario Upgrade Buff"; var AuditProfileUpgradeBuff: Record "NPR Audit Profile Upgrade Buff")
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
        NewPOSAuditProfile: Record "NPR POS Audit Profile";
    begin
        AuditProfileUpgradeBuff.Reset();
        if not AuditProfileUpgradeBuff.IsEmpty then
            AuditProfileUpgradeBuff.DeleteAll();

        POSScenarioUpgradeBuff.Reset();
        if not POSScenarioUpgradeBuff.FindSet() then
            exit;

        repeat
            POSUnit.Reset();
            POSUnit.SetRange("POS Sales Workflow Set", POSScenarioUpgradeBuff.Code);
            POSUnit.SetLoadFields("No.", "POS Sales Workflow Set", "POS Audit Profile");
            if POSUnit.FindSet() then
                repeat
                    if POSAuditProfile.Get(POSUnit."POS Audit Profile") then
                        if ((not POSAuditProfile."Do Not Print Receipt on Sale") and (POSAuditProfile."Do Not Print Receipt on Sale" <> POSScenarioUpgradeBuff."Do Not Print Receipt on Sale")) or
                           (POSAuditProfile."Bin Eject After Sale" <> POSScenarioUpgradeBuff."Bin Eject After Sale") then
                            if not AuditProfileUpgradeBuff.Get(POSUnit."POS Sales Workflow Set", POSUnit."POS Audit Profile") then begin
                                NewPOSAuditProfile := POSAuditProfile;
                                NewPOSAuditProfile."Bin Eject After Sale" := POSScenarioUpgradeBuff."Bin Eject After Sale";

                                if (not NewPOSAuditProfile."Do Not Print Receipt on Sale") and (NewPOSAuditProfile."Do Not Print Receipt on Sale" <> POSScenarioUpgradeBuff."Do Not Print Receipt on Sale") then
                                    NewPOSAuditProfile."Do Not Print Receipt on Sale" := POSScenarioUpgradeBuff."Do Not Print Receipt on Sale";

                                NewPOSAuditProfile.Code := GetAuditProfileUpgradeCode();
                                NewPOSAuditProfile.Insert();

                                AuditProfileUpgradeBuff.Init();
                                AuditProfileUpgradeBuff."Workflow Set Code" := POSUnit."POS Sales Workflow Set";
                                AuditProfileUpgradeBuff."POS Audit Profile Code" := POSUnit."POS Audit Profile";
                                AuditProfileUpgradeBuff."POS New Audit Profile Code" := NewPOSAuditProfile.Code;
                                AuditProfileUpgradeBuff.Insert();
                            end;
                until POSUnit.Next() = 0;
        until POSScenarioUpgradeBuff.Next() = 0;

    end;

    local procedure ProcessAuditProfileUpgradeBuff(var AuditProfileUpgradeBuff: Record "NPR Audit Profile Upgrade Buff")
    var
        POSUnit: Record "NPR POS Unit";
    begin
        AuditProfileUpgradeBuff.Reset();
        if not AuditProfileUpgradeBuff.FindSet() then
            exit;

        repeat
            POSUnit.Reset();
            POSUnit.SetRange("POS Audit Profile", AuditProfileUpgradeBuff."POS Audit Profile Code");
            POSUnit.SetRange("POS Sales Workflow Set", AuditProfileUpgradeBuff."Workflow Set Code");
            if not POSUnit.IsEmpty then
                POSUnit.ModifyAll("POS Audit Profile", AuditProfileUpgradeBuff."POS New Audit Profile Code");
        until AuditProfileUpgradeBuff.Next() = 0;
    end;

    local procedure DeliverCollectDocument()
    var
        POSUnit: Record "NPR POS Unit";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        NPRPOSSalesDocumentSetup: Record "NPR POS Sales Document Setup";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'DeliverCollectDocument');
        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'DeliverCollectDocument')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        POSUnit.Reset();
        POSUnit.SetLoadFields("No.", "POS Sales Workflow Set");
        if POSUnit.FindSet() then
            repeat
                POSSalesWorkflowStep.Reset();
                POSSalesWorkflowStep.SetRange("Workflow Code", 'FINISH_SALE');
                POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", CODEUNIT::"NPR NpCs POSSession Mgt.");
                POSSalesWorkflowStep.SetRange("Subscriber Function", 'DeliverCollectDocument');
                POSSalesWorkflowStep.SetRange(Enabled, true);
                POSSalesWorkflowStep.SetRange("Set Code", POSUnit."POS Sales Workflow Set");
                if not POSSalesWorkflowStep.IsEmpty then begin
                    if not NPRPOSSalesDocumentSetup.Get() then begin
                        NPRPOSSalesDocumentSetup.Init();
                        NPRPOSSalesDocumentSetup."Deliver Collect Document" := true;
                        NPRPOSSalesDocumentSetup.Insert();
                    end else begin
                        if not NPRPOSSalesDocumentSetup."Deliver Collect Document" then begin
                            NPRPOSSalesDocumentSetup."Deliver Collect Document" := true;
                            NPRPOSSalesDocumentSetup.Modify();
                        end;
                    end;
                    POSUnit.FindLast();
                end;
            until POSUnit.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'DeliverCollectDocument'));
        LogMessageStopwatch.LogFinish();
    end;

    procedure DimPopupEvery()
    var
        POSPaymentViewEventSetup: Record "NPR POS Paym. View Event Setup";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'DimPopupEvery');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'DimPopupEvery')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        if POSPaymentViewEventSetup.Get() then
            if POSPaymentViewEventSetup."Popup every" = 0 then begin
                if POSPaymentViewEventSetup."Dimension Popup Enabled" then
                    POSPaymentViewEventSetup."Dimension Popup Enabled" := false;
                POSPaymentViewEventSetup."Popup every" := 1;
                POSPaymentViewEventSetup.Modify();
            end;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'DimPopupEvery'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeLoyaltyProfile()
    var
        POSScenarioUpgradeBuff: Record "NPR POS Scenario Upgrade Buff";
        LoyaltyProfileUpgBuff: Record "NPR Loyalty Profile Upg Buff";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'UpgradeLoyaltyProfile');
        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeLoyaltyProfile')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        CreateLoyaltyProfilePOSScenarioUpgradeBuffer(POSScenarioUpgradeBuff);
        CreateLoyaltyProfileUpgradeBuff(POSScenarioUpgradeBuff, LoyaltyProfileUpgBuff);
        ProcessLoyaltyProfileUpgradeBuff(LoyaltyProfileUpgBuff);

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeLoyaltyProfile'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure CreateLoyaltyProfilePOSScenarioUpgradeBuffer(var POSScenarioUpgradeBuff: Record "NPR POS Scenario Upgrade Buff")
    var
        POSUnit: Record "NPR POS Unit";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSSalesWFSetEntry: Record "NPR POS Sales WF Set Entry";
    begin
        POSScenarioUpgradeBuff.Reset();
        if not POSScenarioUpgradeBuff.IsEmpty then
            POSScenarioUpgradeBuff.DeleteAll();

        POSUnit.Reset();
        POSUnit.SetCurrentKey("POS Sales Workflow Set");
        POSUnit.SetLoadFields("No.", "POS Sales Workflow Set");
        if not POSUnit.FindSet() then
            exit;

        repeat
            if not POSScenarioUpgradeBuff.Get(POSUnit."POS Sales Workflow Set") then begin
                POSScenarioUpgradeBuff.Init();
                POSScenarioUpgradeBuff.Code := POSUnit."POS Sales Workflow Set";
                POSScenarioUpgradeBuff.Insert();
            end;

            POSSalesWorkflowStep.Reset();
            POSSalesWorkflowStep.SetRange("Workflow Code", 'FINISH_SALE');
            POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", CODEUNIT::"NPR MM Loyalty Point Mgt.");
            POSSalesWorkflowStep.SetRange("Subscriber Function", 'PointAssignmentOnSale');
            POSSalesWorkflowStep.SetRange("Set Code", '');
            if (POSScenarioUpgradeBuff.Code <> '') and POSSalesWFSetEntry.Get(POSScenarioUpgradeBuff.Code, 'FINISH_SALE') then
                POSSalesWorkflowStep.SetRange("Set Code", POSScenarioUpgradeBuff.Code);
            POSSalesWorkflowStep.SetLoadFields("Workflow Code", "Subscriber Codeunit ID", "Subscriber Function", Enabled, "Set Code");
            if not POSSalesWorkflowStep.FindFirst() then
                POSScenarioUpgradeBuff."Assign Loyalty On Sale" := false
            else
                POSScenarioUpgradeBuff."Assign Loyalty On Sale" := POSSalesWorkflowStep.Enabled;


            POSScenarioUpgradeBuff.Modify();

            POSUnit.SetRange("POS Sales Workflow Set", POSUnit."POS Sales Workflow Set");
            POSUnit.FindLast();
            POSUnit.SetRange("POS Sales Workflow Set");
        until POSUnit.Next() = 0;
    end;

    local procedure CreateLoyaltyProfileUpgradeBuff(var POSScenarioUpgradeBuff: Record "NPR POS Scenario Upgrade Buff"; var LoyaltyProfileUpgBuff: Record "NPR Loyalty Profile Upg Buff")
    var
        POSUnit: Record "NPR POS Unit";
        POSLoyaltyProfile: Record "NPR MM POS Loyalty Profile";
        NewPOSLoyaltyProfile: Record "NPR MM POS Loyalty Profile";
    begin
        POSScenarioUpgradeBuff.Reset();
        if not POSScenarioUpgradeBuff.FindSet() then
            exit;

        repeat
            POSUnit.Reset();
            POSUnit.SetRange("POS Sales Workflow Set", POSScenarioUpgradeBuff.Code);
            POSUnit.SetLoadFields("No.", "POS Sales Workflow Set", "POS Loyalty Profile");
            if POSUnit.FindSet() then
                repeat
                    POSLoyaltyProfile.Reset();
                    POSLoyaltyProfile.SetRange("Assign Loyalty On Sale", POSScenarioUpgradeBuff."Assign Loyalty On Sale");
                    POSLoyaltyProfile.SetRange(Code, POSUnit."POS Loyalty Profile");
                    if POSLoyaltyProfile.IsEmpty then
                        if not LoyaltyProfileUpgBuff.Get(POSUnit."POS Sales Workflow Set", POSUnit."POS Loyalty Profile") then begin
                            NewPOSLoyaltyProfile.Init();
                            NewPOSLoyaltyProfile.Code := GetPOSLoyaltyProfileUpgradeCode();
                            NewPOSLoyaltyProfile."Assign Loyalty On Sale" := POSScenarioUpgradeBuff."Assign Loyalty On Sale";
                            NewPOSLoyaltyProfile.Insert();

                            LoyaltyProfileUpgBuff.Init();
                            LoyaltyProfileUpgBuff."POS New Loyalty Profile Code" := NewPOSLoyaltyProfile.Code;
                            LoyaltyProfileUpgBuff."POS Loyalty Profile Code" := POSUnit."POS Loyalty Profile";
                            LoyaltyProfileUpgBuff."Workflow Set Code" := POSScenarioUpgradeBuff.Code;
                            LoyaltyProfileUpgBuff.Insert();
                        end;
                until POSUnit.Next() = 0;
        until POSScenarioUpgradeBuff.Next() = 0;

    end;

    local procedure ProcessLoyaltyProfileUpgradeBuff(var NPRLoyaltyProfileUpgBuff: Record "NPR Loyalty Profile Upg Buff")
    var
        POSUnit: Record "NPR POS Unit";
    begin
        NPRLoyaltyProfileUpgBuff.Reset();
        if not NPRLoyaltyProfileUpgBuff.FindSet() then
            exit;

        repeat
            POSUnit.Reset();
            POSUnit.SetRange("POS Loyalty Profile", NPRLoyaltyProfileUpgBuff."POS Loyalty Profile Code");
            POSUnit.SetRange("POS Sales Workflow Set", NPRLoyaltyProfileUpgBuff."Workflow Set Code");
            if not POSUnit.IsEmpty then
                POSUnit.ModifyAll("POS Loyalty Profile", NPRLoyaltyProfileUpgBuff."POS New Loyalty Profile Code");
        until NPRLoyaltyProfileUpgBuff.Next() = 0;
    end;

    local procedure UpgradeTicketProfile()
    var
        POSScenarioUpgradeBuff: Record "NPR POS Scenario Upgrade Buff";
        TicketProfileUpgBuff: Record "NPR Ticket Profile Upg Buff";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Scenarios', 'UpgradeTicketProfile');
        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeTicketProfile')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        CreateTicketProfilePOSScenarioUpgradeBuffer(POSScenarioUpgradeBuff);
        CreateTicketProfileUpgradeBuff(POSScenarioUpgradeBuff, TicketProfileUpgBuff);
        ProcessTicketProfileUpgradeBuff(TicketProfileUpgBuff);

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeTicketProfile'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure CreateTicketProfilePOSScenarioUpgradeBuffer(var POSScenarioUpgradeBuff: Record "NPR POS Scenario Upgrade Buff")
    var
        POSUnit: Record "NPR POS Unit";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSSalesWFSetEntry: Record "NPR POS Sales WF Set Entry";
    begin
        POSScenarioUpgradeBuff.Reset();
        if not POSScenarioUpgradeBuff.IsEmpty then
            POSScenarioUpgradeBuff.DeleteAll();

        POSUnit.Reset();
        POSUnit.SetCurrentKey("POS Sales Workflow Set");
        POSUnit.SetLoadFields("No.", "POS Sales Workflow Set");
        if not POSUnit.FindSet() then
            exit;

        repeat
            if not POSScenarioUpgradeBuff.Get(POSUnit."POS Sales Workflow Set") then begin
                POSScenarioUpgradeBuff.Init();
                POSScenarioUpgradeBuff.Code := POSUnit."POS Sales Workflow Set";
                POSScenarioUpgradeBuff.Insert();
            end;

            POSSalesWorkflowStep.Reset();
            POSSalesWorkflowStep.SetRange("Workflow Code", 'FINISH_SALE');
            POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", CODEUNIT::"NPR TM Ticket Management");
            POSSalesWorkflowStep.SetRange("Subscriber Function", 'PrintTicketsOnSale');
            POSSalesWorkflowStep.SetRange("Set Code", '');
            if (POSScenarioUpgradeBuff.Code <> '') and POSSalesWFSetEntry.Get(POSScenarioUpgradeBuff.Code, 'FINISH_SALE') then
                POSSalesWorkflowStep.SetRange("Set Code", POSScenarioUpgradeBuff.Code);
            POSSalesWorkflowStep.SetLoadFields("Workflow Code", "Subscriber Codeunit ID", "Subscriber Function", Enabled, "Set Code");
            if not POSSalesWorkflowStep.FindFirst() then
                POSScenarioUpgradeBuff."Print Ticket On Sale" := false
            else
                POSScenarioUpgradeBuff."Print Ticket On Sale" := POSSalesWorkflowStep.Enabled;


            POSScenarioUpgradeBuff.Modify();

            POSUnit.SetRange("POS Sales Workflow Set", POSUnit."POS Sales Workflow Set");
            POSUnit.FindLast();
            POSUnit.SetRange("POS Sales Workflow Set");
        until POSUnit.Next() = 0;
    end;

    local procedure CreateTicketProfileUpgradeBuff(var POSScenarioUpgradeBuff: Record "NPR POS Scenario Upgrade Buff"; var TicketProfileUpgBuff: Record "NPR Ticket Profile Upg Buff")
    var
        POSUnit: Record "NPR POS Unit";
        POSTicketProfile: Record "NPR TM POS Ticket Profile";
        NewPOSTicketProfile: Record "NPR TM POS Ticket Profile";
    begin
        POSScenarioUpgradeBuff.Reset();
        if not POSScenarioUpgradeBuff.FindSet() then
            exit;

        repeat
            POSUnit.Reset();
            POSUnit.SetRange("POS Sales Workflow Set", POSScenarioUpgradeBuff.Code);
            POSUnit.SetLoadFields("No.", "POS Sales Workflow Set", "POS Ticket Profile");
            if POSUnit.FindSet() then
                repeat
                    POSTicketProfile.Reset();
                    POSTicketProfile.SetRange("Print Ticket On Sale", POSScenarioUpgradeBuff."Print Ticket On Sale");
                    POSTicketProfile.SetRange(Code, POSUnit."POS Ticket Profile");
                    if POSTicketProfile.IsEmpty then
                        if not TicketProfileUpgBuff.Get(POSUnit."POS Sales Workflow Set", POSUnit."POS Ticket Profile") then begin
                            NewPOSTicketProfile.Init();
                            NewPOSTicketProfile.Code := GetPOSTicketProfileUpgradeCode();
                            NewPOSTicketProfile."Print Ticket On Sale" := POSScenarioUpgradeBuff."Print Ticket On Sale";
                            NewPOSTicketProfile.Insert();

                            TicketProfileUpgBuff.Init();
                            TicketProfileUpgBuff."POS New Ticket Profile Code" := NewPOSTicketProfile.Code;
                            TicketProfileUpgBuff."POS Ticket Profile Code" := POSUnit."POS Ticket Profile";
                            TicketProfileUpgBuff."Workflow Set Code" := POSScenarioUpgradeBuff.Code;
                            TicketProfileUpgBuff.Insert();
                        end;
                until POSUnit.Next() = 0;
        until POSScenarioUpgradeBuff.Next() = 0;
    end;

    local procedure ProcessTicketProfileUpgradeBuff(var NPRTicketProfileUpgBuff: Record "NPR Ticket Profile Upg Buff")
    var
        POSUnit: Record "NPR POS Unit";
    begin
        NPRTicketProfileUpgBuff.Reset();
        if not NPRTicketProfileUpgBuff.FindSet() then
            exit;

        repeat
            POSUnit.Reset();
            POSUnit.SetRange("POS Ticket Profile", NPRTicketProfileUpgBuff."POS Ticket Profile Code");
            POSUnit.SetRange("POS Sales Workflow Set", NPRTicketProfileUpgBuff."Workflow Set Code");
            if not POSUnit.IsEmpty then
                POSUnit.ModifyAll("POS Ticket Profile", NPRTicketProfileUpgBuff."POS New Ticket Profile Code");
        until NPRTicketProfileUpgBuff.Next() = 0;
    end;

    local procedure GetAuditProfileUpgradeCode() AuditProfileUpgradeCode: Code[20];
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        InitialValueCodeLbl: Label 'UPG_0000000000000001';
    begin
        AuditProfileUpgradeCode := InitialValueCodeLbl;

        while POSAuditProfile.Get(AuditProfileUpgradeCode) do
            AuditProfileUpgradeCode := IncStr(AuditProfileUpgradeCode);
    end;

    local procedure GetPOSMemberProfileUpgradeCode() MemberProfileUpgradeCode: Code[20];
    var
        POSMemberProfile: Record "NPR MM POS Member Profile";
        InitialValueCodeLbl: Label 'UPG_0000000000000001';
    begin
        MemberProfileUpgradeCode := InitialValueCodeLbl;

        while POSMemberProfile.Get(MemberProfileUpgradeCode) do
            MemberProfileUpgradeCode := IncStr(MemberProfileUpgradeCode);
    end;

    local procedure GetPOSLoyaltyProfileUpgradeCode() LoyaltyProfileUpgradeCode: Code[20];
    var
        POSLoyaltyProfile: Record "NPR MM POS Loyalty Profile";
        InitialValueCodeLbl: Label 'UPG_0000000000000001';
    begin
        LoyaltyProfileUpgradeCode := InitialValueCodeLbl;

        while POSLoyaltyProfile.Get(LoyaltyProfileUpgradeCode) do
            LoyaltyProfileUpgradeCode := IncStr(LoyaltyProfileUpgradeCode);
    end;

    local procedure GetPOSTicketProfileUpgradeCode() TicketProfileUpgradeCode: Code[20];
    var
        POSTicketProfile: Record "NPR TM POS Ticket Profile";
        InitialValueCodeLbl: Label 'UPG_0000000000000001';
    begin
        TicketProfileUpgradeCode := InitialValueCodeLbl;

        while POSTicketProfile.Get(TicketProfileUpgradeCode) do
            TicketProfileUpgradeCode := IncStr(TicketProfileUpgradeCode);
    end;
}