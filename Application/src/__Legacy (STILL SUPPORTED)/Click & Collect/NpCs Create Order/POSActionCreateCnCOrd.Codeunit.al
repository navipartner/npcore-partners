codeunit 6151206 "NPR POS Action Create CnC Ord." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        ActionDescriptionLbl: Label 'This built-in action create collect order from one to another store.';
        ParamFromStoreCode_OptLbl: Label 'POS Relation,Store Code Parameter,Location Filter Parameter', MaxLength = 250, Locked = true;
        ParamFromStoreCode_OptCaptionsLbl: Label 'POS Relation,Store Code Parameter,Location Filter Parameter', MaxLength = 250;
        ParamFromStoreCode_NameLbl: Label 'From Store Code';
        ParamFromStoreCode_DescLbl: Label 'Specifies from Store Code';
        ParamStoreCode_CptLbl: Label 'Store Code';
        ParamStoreCode_DescLbl: Label 'Specifies Store Code';
        ParamLocFilter_CptLbl: Label 'Location Filter';
        ParamLocFilter_DescLbl: Label 'Specifies Location Filter';
        ParamPrepaymentValue_CptLbl: Label 'Fixed Prepayment Value';
        ParamPrepaymentValue_DescLbl: Label 'Specifies Fixed Prepayment Value';
        ParamCheckCustomerCredit_CptLbl: Label 'Check Customer Credit';
        ParamCheckCustomerCredit_DescLbl: Label 'Check Customer Credit';
        ConfirmMissingStockLbl: Label 'Confirm Missing Stock';
        CaptionPrepaymentDlg: Label 'Prompt Prepayment';
        TextPrepaymentPctLead: Label 'Please specify prepayment %';
        DescPrepaymentDlg: Label 'Ask user for prepayment value.';
        CaptionPrepayIsAmount: Label 'Prepayment Amount Input';
        TextPrepaymentAmountLead: Label 'Please specify prepayment amount';
        DescPrepayIsAmount: Label 'Input prepayment amount instead of percent in prompt';
        TextPrepaymentTitle: Label 'Prepayment';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddLabel('prepaymentDialogTitle', TextPrepaymentTitle);
        WorkflowConfig.AddLabel('prepaymentPctLead', TextPrepaymentPctLead);
        WorkflowConfig.AddLabel('prepaymentAmountLead', TextPrepaymentAmountLead);
        WorkflowConfig.AddLabel('ConfirmSetStoreForMissingStock', ConfirmMissingStockLbl);
        WorkflowConfig.AddOptionParameter('fromStoreCode',
#pragma warning disable AA0139
                                          ParamFromStoreCode_OptLbl,
                                          SelectStr(1, ParamFromStoreCode_OptLbl),
#pragma warning restore                                          
                                          ParamFromStoreCode_NameLbl,
                                          ParamFromStoreCode_DescLbl,
                                          ParamFromStoreCode_OptCaptionsLbl);
        WorkflowConfig.AddTextParameter('storeCode', '', ParamStoreCode_CptLbl, ParamStoreCode_DescLbl);
        WorkflowConfig.AddTextParameter('locationFilter', '', ParamLocFilter_CptLbl, ParamLocFilter_DescLbl);
        WorkflowConfig.AddDecimalParameter('prepaymentPercent', 0, ParamPrepaymentValue_CptLbl, ParamPrepaymentValue_DescLbl);
        WorkflowConfig.AddBooleanParameter('checkCustomerCredit', true, ParamCheckCustomerCredit_CptLbl, ParamCheckCustomerCredit_DescLbl);
        WorkflowConfig.AddBooleanParameter('prepaymentDialog', true, CaptionPrepaymentDlg, DescPrepaymentDlg);
        WorkflowConfig.AddBooleanParameter('prepayment_is_amount', false, CaptionPrepayIsAmount, DescPrepayIsAmount);
        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSaleLine());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; SaleMgr: Codeunit "NPR POS Sale"; SaleLineMgr: Codeunit "NPR POS Sale Line"; PaymentLineMgr: Codeunit "NPR POS Payment Line"; SetupMgr: Codeunit "NPR POS Setup");
    begin
        case Step of
            'SelectFromStoreCodeFromPOSRelation':
                begin
                    SelectPOSRelation(Context);
                end;
            'SelectFromStoreCodeFromStoreCodeParameter':
                begin
                    SelectStoreCodeParameter(Context);
                end;
            'SelectFromStoreCodeFromLocationFilterParameter':
                begin
                    SelectLocationFilterParameter(Context);
                end;
            'SelectToStoreCode':
                begin
                    SelectToStoreCode(Context);
                end;
            'SelectWorkflow':
                begin
                    SelectWorkflow(Context);
                end;
            'SelectCustomer':
                begin
                    SelectCustomer(Context);
                end;
            'CreateCollectOrder':
                begin
                    CreateCollectOrder(Context);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupStoreCode(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        NpCsStore: Record "NPR NpCs Store";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'storeCode' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        Handled := true;

        if StrLen(POSParameterValue.Value) > MaxStrLen(NpCsStore.Code) then
            if NpCsStore.Get(UpperCase(POSParameterValue.Value)) then;

        NpCsStore.SetRange("Local Store", true);
        if Page.RunModal(0, NpCsStore) = Action::LookupOK then
            POSParameterValue.Value := NpCsStore.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateStoreCode(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        NpCsStore: Record "NPR NpCs Store";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'storeCode' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not NpCsStore.Get(POSParameterValue.Value) then begin
            NpCsStore.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            NpCsStore.SetRange("Local Store", true);
            if NpCsStore.FindFirst() then
                POSParameterValue.Value := NpCsStore.Code;
        end;

        NpCsStore.Get(POSParameterValue.Value);
        NpCsStore.TestField("Local Store");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupLocationFilter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'locationFilter' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        Handled := true;

        if StrLen(POSParameterValue.Value) > MaxStrLen(Location.Code) then
            if Location.Get(UpperCase(POSParameterValue.Value)) then;

        if Page.RunModal(0, Location) = Action::LookupOK then
            POSParameterValue.Value := Location.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateLocationFilter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'locationFilter' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        Location.SetFilter(Code, POSParameterValue.Value);
        if not Location.FindFirst() then begin
            Location.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            if Location.FindFirst() then
                POSParameterValue.Value := Location.Code;
        end;
    end;

    local procedure SelectPOSRelation(Context: Codeunit "NPR POS JSON Helper")
    var
        StoreCode: Code[20];
        NpCsPOSActionCreOrderB: Codeunit "NPR POSAction Create CnC Ord B";
    begin
        StoreCode := NpCsPOSActionCreOrderB.SelectPOSRelation();
        Context.SetContext('fromStoreCode', StoreCode);
    end;

    local procedure SelectStoreCodeParameter(Context: Codeunit "NPR POS JSON Helper")
    var
        NpCsStore: Record "NPR NpCs Store";
        StoreCode: Text;
    begin
        StoreCode := UpperCase(Context.GetStringParameter('storeCode'));
        NpCsStore.Get(StoreCode);

        Context.SetContext('fromStoreCode', NpCsStore.Code);
    end;

    local procedure SelectLocationFilterParameter(Context: Codeunit "NPR POS JSON Helper")
    var
        NpCsStore: Record "NPR NpCs Store";
        LocationFilter: Text;
        LastRec: Text;
    begin
        LocationFilter := UpperCase(Context.GetStringParameter('locationFilter'));
        NpCsStore.SetRange("Local Store", true);
        NpCsStore.SetFilter("Location Code", LocationFilter);
        NpCsStore.FindLast();
        LastRec := Format(NpCsStore);

        NpCsStore.FindFirst();
        if LastRec <> Format(NpCsStore) then begin
            if Page.RunModal(0, NpCsStore) <> Action::LookupOK then
                exit;
        end;

        Context.SetContext('fromStoreCode', NpCsStore.Code);
    end;

    local procedure SelectToStoreCode(Context: Codeunit "NPR POS JSON Helper")
    var
        TempNpCsStore: Record "NPR NpCs Store" temporary;
        FromStoreCode: Code[20];
        NpCsPOSActionCreOrderB: Codeunit "NPR POSAction Create CnC Ord B";
        NpCsPOSActionEvents: Codeunit "NPR NpCs POS Action Events";
        IsHandled: Boolean;
        MissingStockInCompanyLbl: Label 'All Items might not be in stock in %1. Do you still wish to continue?', Comment = '%1="NPR NpCs Store".Name';
    begin
        FromStoreCode := CopyStr(UpperCase(Context.GetString('fromStoreCode')), 1, MaxStrLen(FromStoreCode));

        NpCsPOSActionEvents.OnBeforeSelectToStore(TempNpCsStore, FromStoreCode, IsHandled);
        if IsHandled then begin
            if TempNpCsStore.Code <> '' then
                Context.SetContext('toStoreCode', TempNpCsStore.Code);
            exit;
        end;
        if not NpCsPOSActionCreOrderB.SelectToStoreCode(TempNpCsStore, FromStoreCode) then
            exit;

        if not TempNpCsStore."In Stock" then begin
            Context.SetContext('ConfirmMissingStock', true);
            Context.SetContext('MissingStockInCompanyLbl', StrSubstNo(MissingStockInCompanyLbl, TempNpCsStore.Name));
        end;
        Context.SetContext('toStoreCode', TempNpCsStore.Code);
    end;

    local procedure SelectWorkflow(JSON: Codeunit "NPR POS JSON Helper")
    var
        StoreCode: Text;
        WorkflowCode: Code[20];
        NpCsPOSActionCreOrderB: Codeunit "NPR POSAction Create CnC Ord B";
    begin
        StoreCode := UpperCase(JSON.GetString('toStoreCode'));
        WorkflowCode := NpCsPOSActionCreOrderB.SelectWorkflow(StoreCode);
        JSON.SetContext('workflowCode', WorkflowCode);
    end;

    local procedure SelectCustomer(Context: Codeunit "NPR POS JSON Helper")
    var
        NpCsPOSActionCreOrderB: Codeunit "NPR POSAction Create CnC Ord B";
        CustomerNo: Code[20];
        WorkflowCode: Code[20];
    begin
        WorkflowCode := CopyStr(Context.GetString('workflowCode'), 1, MaxStrLen(WorkflowCode));
        CustomerNo := NpCsPOSActionCreOrderB.SelectCustomer(WorkflowCode);
        Context.SetContext('customerNo', CustomerNo);
    end;

    local procedure CreateCollectOrder(Context: Codeunit "NPR POS JSON Helper")
    var
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        FromStoreCode: Code[20];
        ToStoreCode: Code[20];
        WorkflowCode: Code[20];
        PrepaymentValue: Decimal;
        PrepaymentIsAmount: Boolean;
        NpCsPOSActionCreOrderB: Codeunit "NPR POSAction Create CnC Ord B";
    begin
        FromStoreCode := CopyStr(Context.GetString('fromStoreCode'), 1, MaxStrLen(FromStoreCode));
        ToStoreCode := CopyStr(Context.GetString('toStoreCode'), 1, MaxStrLen(ToStoreCode));
        WorkflowCode := CopyStr(Context.GetString('workflowCode'), 1, MaxStrLen(WorkflowCode));
        PrepaymentValue := Context.GetDecimal('prepaymentValue');
        PrepaymentIsAmount := Context.GetBooleanParameter('prepayment_is_amount');

        ExportToDocument(Context, RetailSalesDocMgt);
        NpCsPOSActionCreOrderB.CreateCollectOrder(FromStoreCode, ToStoreCode, WorkflowCode, PrepaymentValue, RetailSalesDocMgt, PrepaymentIsAmount);
    end;

    local procedure ExportToDocument(Context: Codeunit "NPR POS JSON Helper"; RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.")
    var
        NpCsPOSActionCreOrderB: Codeunit "NPR POSAction Create CnC Ord B";
        CustomerNo: Text;
        checkCustomerCredit: Boolean;
    begin
        CustomerNo := Context.GetString('customerNo');
        checkCustomerCredit := Context.GetBooleanParameter('checkCustomerCredit');
        NpCsPOSActionCreOrderB.ExportToDocument(CustomerNo, RetailSalesDocMgt, checkCustomerCredit);
    end;

    procedure ActionCode(): Text
    begin
        exit(Format(Enum::"NPR POS Workflow"::CREATE_COLLECT_ORD));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionCreateCnCOrd.js###
'let main=async({workflow:a,context:e,popup:t,parameters:i,captions:r})=>{switch(i.fromStoreCode+""){case"0":await a.respond("SelectFromStoreCodeFromPOSRelation");break;case"1":await a.respond("SelectFromStoreCodeFromStoreCodeParameter");break;case"2":await a.respond("SelectFromStoreCodeFromLocationFilterParameter");break}!e.fromStoreCode||!e.toStoreCode&&(await a.respond("SelectToStoreCode"),e.ConfirmMissingStock&&e.MissingStockInCompanyLbl.length>0&&!await t.confirm({title:r.ConfirmSetStoreForMissingStock,caption:e.MissingStockInCompanyLbl}))||(e.workflowCode||await a.respond("SelectWorkflow"),e.customerNo||await a.respond("SelectCustomer"),i.prepaymentDialog?i.prepayment_is_amount?e.prepaymentValue=await t.numpad({caption:r.prepaymentAmountLead,title:r.prepaymentDialogTitle,value:i.prepaymentPercent}):e.prepaymentValue=await t.numpad({caption:r.prepaymentPctLead,title:r.prepaymentDialogTitle,value:i.prepaymentPercent}):e.prepaymentValue=i.prepaymentPercent,await a.respond("CreateCollectOrder"),e.HandlePrepaymentFailed&&e.HandlePrepaymentFailReasonMsg.length>0&&await t.message(e.HandlePrepaymentFailReasonMsg))};'
        );
    end;
}
