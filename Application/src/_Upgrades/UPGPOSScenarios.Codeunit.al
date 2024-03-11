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

        //FINISH_CREDIT_SALE scenario
        DimPopupEvery();
        EjectPaymentBinOnCreditSale();

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
        if not POSSalesWorkflowStep.IsEmpty() then
            if not POSReceiptProfile.IsEmpty() then
                POSReceiptProfile.ModifyAll("E-mail Receipt On Sale", true);

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'EmailReceiptOnSale'));
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

}