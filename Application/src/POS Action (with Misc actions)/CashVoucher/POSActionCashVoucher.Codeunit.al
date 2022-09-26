codeunit 6184633 "NPR POS Action: Cash Voucher" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action handles Cashout Retail Vouchers';
        VoucherType_CptLbl: Label 'Voucher Type';
        DeductCommision_CptLbl: Label 'Deduct Commision';
        DeductCommision_DescLbl: Label 'Specifies if Commision should be deducted from Voucher value';
        CommisionPercentage_CptLbl: Label 'Commision %';
        CommisionAccount_CptLbl: Label 'Commision G/L Account';
        CommisionAccount_DescLbl: Label 'Specifies G/L Account for posting Commision';
        ScanRetailVoucherTitleLbl: Label 'Retail Voucher';
        ScanRetailVoucher_CptLbl: Label 'Enter Reference No.';
        InvalidParametersLbl: Label 'Parameters for commission is incomplete';
        EnableVoucherList_CptLbl: Label 'Open Voucher List';
        EnableVoucherList_DescLbl: Label 'Open Voucher List if Reference No. is blank';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('ScanRetailVoucherTitle', ScanRetailVoucherTitleLbl);
        WorkflowConfig.AddLabel('ScanRetailVoucherCaption', ScanRetailVoucher_CptLbl);
        WorkflowConfig.AddLabel('InvalidParameters', InvalidParametersLbl);
        WorkflowConfig.AddTextParameter('VoucherType', '', VoucherType_CptLbl, VoucherType_CptLbl);
        WorkflowConfig.AddBooleanParameter('DeductCommision', false, DeductCommision_CptLbl, DeductCommision_DescLbl);
        WorkflowConfig.AddDecimalParameter('CommisionPercentage', 0, CommisionPercentage_CptLbl, CommisionPercentage_CptLbl);
        WorkflowConfig.AddTextParameter('CommisionAccount', '', CommisionAccount_CptLbl, CommisionAccount_DescLbl);
        WorkflowConfig.AddBooleanParameter('EnableVoucherList', false, EnableVoucherList_CptLbl, EnableVoucherList_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'SetVoucherType':
                FrontEnd.WorkflowResponse(SetVoucherType(Context));
            'ScanVoucher':
                FrontEnd.WorkflowResponse(ProcessVoucher(Context, Sale, PaymentLine, SaleLine));
            'InsertCommision':
                FrontEnd.WorkflowResponse(InsertCommision(Context, PaymentLine, SaleLine));
        end;
    end;

    local procedure GetVoucherType(Context: Codeunit "NPR POS JSON Helper"): Code[20]
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        VoucherType: Code[20];
    begin
        if Context.GetStringParameter('VoucherType') <> '' then begin
            VoucherType := CopyStr(Context.GetStringParameter('VoucherType'), 1, MaxStrLen(VoucherType));
            NpRvVoucherType.Get(VoucherType);
        end;
        if VoucherType = '' then
            if Page.RunModal(0, NpRvVoucherType) <> Action::LookupOK then
                exit;
        VoucherType := NpRvVoucherType.Code;

        exit(VoucherType);
    end;

    local procedure SetVoucherType(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        VoucherType: Code[20];
    begin
        VoucherType := GetVoucherType(Context);
        Response.Add('voucherType', VoucherType);
    end;

    local procedure SetReferenceNo(Context: Codeunit "NPR POS JSON Helper"): Text[50]
    var
        Voucher: Record "NPR NpRv Voucher";
        NpRvVouchers: Page "NPR NpRv Vouchers";
        VoucherType: Code[20];
        ReferenceNo: Text[50];
    begin
        VoucherType := Context.GetString('voucherType');

        Voucher.SetCurrentKey("Voucher Type");
        Voucher.SetRange("Voucher Type", VoucherType);

        Clear(NpRvVouchers);
        NpRvVouchers.LookupMode := true;
        NpRvVouchers.SetTableView(Voucher);
        if NpRvVouchers.RunModal() = Action::LookupOK then begin
            NpRvVouchers.GetRecord(Voucher);
            ReferenceNo := Voucher."Reference No.";
        end;

        exit(ReferenceNo);

    end;

    local procedure ProcessVoucher(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        VoucherType: Code[20];
        ReferenceNo: Text[50];
        CashVoucherB: Codeunit "NPR Cashout Voucher B";
        POSSession: Codeunit "NPR POS Session";
        Success: Boolean;
        VoucherListEnabled: Boolean;
    begin
        Context.GetBooleanParameter('EnableVoucherList', VoucherListEnabled);
        VoucherType := Context.GetString('voucherType');
        ReferenceNo := Context.GetString('VoucherRefNo');//is it scanned
        if ReferenceNo = '' then
            if VoucherListEnabled then
                ReferenceNo := SetReferenceNo(Context);

        if ReferenceNo <> '' then begin
            CashVoucherB.ApplyVoucherPayment(VoucherType, ReferenceNo, Sale, PaymentLine, SaleLine);
            POSSession.ChangeViewSale();
            Success := true;
        end;
        Response.Add('voucherSet', Success);
        exit(Response);

    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionCashVoucher.js###
'let main=async({workflow:n,parameters:e,popup:c,captions:o})=>{debugger;if(e.DeductCommision&&(e.CommisionPercentage===0||e.CommisionAccount==="")){c.error(o.InvalidParameters);return}let t;const{voucherType:i}=await n.respond("SetVoucherType");if(i===null||i===""||(t=await c.input({title:o.ScanRetailVoucherTitle,caption:o.ScanRetailVoucherCaption}),t===null))return;const{voucherSet:r}=await n.respond("ScanVoucher",{VoucherRefNo:t,voucherType:i});r&&e.DeductCommision&&await n.respond("InsertCommision",{voucherType:i})};'
        );
    end;

    local procedure InsertCommision(Context: Codeunit "NPR POS JSON Helper"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        CashVoucherB: Codeunit "NPR Cashout Voucher B";
        CommisionPercentage: Decimal;
        GLAccount: Code[20];
        VoucherType: Code[20];
        Success: Boolean;
    begin
        CommisionPercentage := Context.GetDecimalParameter('CommisionPercentage');
        VoucherType := Context.GetString('voucherType');
        GLAccount := Context.GetStringParameter('CommisionAccount');

        Success := CashVoucherB.InsertCommision(GLAccount, VoucherType, CommisionPercentage, PaymentLine, SaleLine);
        Response.Add('success', Success);

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnValidateVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> Format(Enum::"NPR POS Workflow"::CASHOUT_VOUCHER) then
            exit;
        if POSParameterValue.Name <> 'VoucherType' then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not NpRvVoucherType.Get(POSParameterValue.Value) then begin
            NpRvVoucherType.SetFilter(Code, (StrSubstNo('%1*', POSParameterValue.Value)));
            if NpRvVoucherType.FindFirst() then
                POSParameterValue.Value := NpRvVoucherType.Code;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> Format(Enum::"NPR POS Workflow"::CASHOUT_VOUCHER) then
            exit;
        if POSParameterValue.Name <> 'VoucherType' then
            exit;

        Handled := true;

        if Page.RunModal(0, NpRvVoucherType) = Action::LookupOK then
            POSParameterValue.Value := NpRvVoucherType.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupCommisionAccount(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        GLAccount: Record "G/L Account";
    begin
        if POSParameterValue."Action Code" <> Format(Enum::"NPR POS Workflow"::CASHOUT_VOUCHER) then
            exit;
        if POSParameterValue.Name <> 'CommisionAccount' then
            exit;

        Handled := true;

        if Page.RunModal(0, GLAccount) = Action::LookupOK then
            POSParameterValue.Value := GLAccount."No.";
    end;

}
