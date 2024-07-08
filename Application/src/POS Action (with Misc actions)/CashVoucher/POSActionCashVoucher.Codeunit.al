codeunit 6184633 "NPR POS Action: Cash Voucher" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action handles Cashout Retail Vouchers';
        VoucherType_CptLbl: Label 'Voucher Type';
        DeductCommision_CptLbl: Label 'Deduct Fee';
        DeductCommision_DescLbl: Label 'Specifies if Fee should be deducted from Voucher value';
        CommisionPercentage_CptLbl: Label 'Fee %';
        CommisionAmount_CptLbl: Label 'Fee Amount';
        CommisionType_CptLbl: Label 'Fee Type';
        CommisionType_DescLbl: Label 'Specifies the Fee Type';
        CommisionTypeOpt_CptLbl: Label 'Percentage,Amount';
        CommisionTypeOptLbl: Label 'Percentage,Amount';
        CommisionAccount_CptLbl: Label 'Fee G/L Account';
        CommisionAccount_DescLbl: Label 'Specifies G/L Account for posting Fee';
        ScanRetailVoucherTitleLbl: Label 'Retail Voucher';
        ScanRetailVoucher_CptLbl: Label 'Enter Reference No.';
        InvalidParametersLbl: Label 'Parameters for fee are incompleted';
        EnableVoucherList_CptLbl: Label 'Open Voucher List';
        EnableVoucherList_DescLbl: Label 'Open Voucher List if Reference No. is blank';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('ScanRetailVoucherTitle', ScanRetailVoucherTitleLbl);
        WorkflowConfig.AddLabel('ScanRetailVoucherCaption', ScanRetailVoucher_CptLbl);
        WorkflowConfig.AddLabel('InvalidParameters', InvalidParametersLbl);
        WorkflowConfig.AddTextParameter('VoucherType', '', VoucherType_CptLbl, VoucherType_CptLbl);
        WorkflowConfig.AddOptionParameter('CommisionType',
                                          CommisionTypeOptLbl,
#pragma warning disable AA0139
                                          SelectStr(1, CommisionTypeOpt_CptLbl),
#pragma warning restore
                                          CommisionType_CptLbl,
                                          CommisionType_DescLbl,
                                          CommisionTypeOpt_CptLbl);
        WorkflowConfig.AddBooleanParameter('DeductCommision', false, DeductCommision_CptLbl, DeductCommision_DescLbl);
        WorkflowConfig.AddDecimalParameter('CommisionPercentage', 0, CommisionPercentage_CptLbl, CommisionPercentage_CptLbl);
        WorkflowConfig.AddDecimalParameter('CommisionAmount', 0, CommisionAmount_CptLbl, CommisionAmount_CptLbl);
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
# pragma warning disable AA0139
        VoucherType := Context.GetString('voucherType');
# pragma warning restore

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
        CommisionType: Option Percentage,Amount;
        CommisionAmt: Decimal;
    begin
        Context.GetBooleanParameter('EnableVoucherList', VoucherListEnabled);
# pragma warning disable AA0139
        VoucherType := Context.GetString('voucherType');
        ReferenceNo := Context.GetString('VoucherRefNo');//is it scanned
        CommisionAmt := Context.GetDecimalParameter('CommisionAmount');
        CommisionType := Context.GetIntegerParameter('CommisionType');
# pragma warning restore
        if ReferenceNo = '' then
            if VoucherListEnabled then
                ReferenceNo := SetReferenceNo(Context);

        if ReferenceNo <> '' then begin
            if CommisionType = CommisionType::Amount then
                CheckCommisionAmount(VoucherType, ReferenceNo, CommisionAmt);
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
'let main=async({workflow:r,parameters:e,popup:n,captions:i})=>{debugger;if(e.DeductCommision){if(e.CommisionAccount===""){n.error(i.InvalidParameters);return}if(e.CommisionPercentage==0&&e.CommisionType==0){n.error(i.InvalidParameters);return}if(e.CommisionAmount==0&&e.CommisionType==1){n.error(i.InvalidParameters);return}}let t;const{voucherType:o}=await r.respond("SetVoucherType");if(o===null||o===""||(t=await n.input({title:i.ScanRetailVoucherTitle,caption:i.ScanRetailVoucherCaption}),t===null))return;const{voucherSet:u}=await r.respond("ScanVoucher",{VoucherRefNo:t,voucherType:o});u&&e.DeductCommision&&await r.respond("InsertCommision",{voucherType:o})};'
        );
    end;

    local procedure InsertCommision(Context: Codeunit "NPR POS JSON Helper"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        CashVoucherB: Codeunit "NPR Cashout Voucher B";
        CommisionAmt: Decimal;
        CommisionType: Option Percentage,Amount;
        GLAccount: Code[20];
        VoucherType: Code[20];
        Success: Boolean;
    begin
        CommisionType := Context.GetIntegerParameter('CommisionType');

        if CommisionType = CommisionType::Percentage then
            CommisionAmt := Context.GetDecimalParameter('CommisionPercentage')
        else
            CommisionAmt := Context.GetDecimalParameter('CommisionAmount');

# pragma warning disable AA0139
        VoucherType := Context.GetString('voucherType');
        GLAccount := Context.GetStringParameter('CommisionAccount');
#pragma warning restore
        Success := CashVoucherB.InsertCommision(GLAccount, VoucherType, CommisionType, CommisionAmt, PaymentLine, SaleLine);
        Response.Add('success', Success);
    end;

    local procedure CheckCommisionAmount(VoucherType: Code[20]; ReferenceNo: Text[50]; CommisionAmt: Decimal)
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        NpRvVoucher: Record "NPR NpRv Voucher";
        InvalidCommisionAmountLbl: Label 'Commision Amount is higher than Voucher Amount.';
        VoucherNotFoundErrorLbl: Label 'Voucher with Reference %1 and Voucher Type %2 is not found.', Comment = '%1 - specifies Reference No., %2 - specifies Voucher Type Code';
    begin
        NpRvVoucher.SetAutoCalcFields(Amount);
        if not NpRvVoucherMgt.FindVoucher(VoucherType, ReferenceNo, NpRvVoucher) then
            Error(VoucherNotFoundErrorLbl, ReferenceNo, VoucherType);

        if CommisionAmt > NpRvVoucher.Amount then
            Error(InvalidCommisionAmountLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnValidateCommisionAmount(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        POSParameterValueVoucherType: Record "NPR POS Parameter Value";
        CommisionAmt: Decimal;
        CommisionAmtHigherThatAllowedErrLbl: Label 'Commision Amount is higher than Minimum Amount Issue specified on the Voucher Type. %1', Comment = '%1 - Specifies the Voucher Type';
    begin
        if POSParameterValue."Action Code" <> Format(Enum::"NPR POS Workflow"::CASHOUT_VOUCHER) then
            exit;
        if POSParameterValue.Name <> 'CommisionAmount' then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValueVoucherType.SetRange("Action Code", Format(Enum::"NPR POS Workflow"::CASHOUT_VOUCHER));
        POSParameterValueVoucherType.SetRange("Name", 'VoucherType');

        if not POSParameterValueVoucherType.FindFirst() then
            exit;
        if not NpRvVoucherType.Get(POSParameterValueVoucherType.Value) then
            exit;
        if not Evaluate(CommisionAmt, POSParameterValue.Value) then
            exit;

        if CommisionAmt > NpRvVoucherType."Minimum Amount Issue" then
            Error(CommisionAmtHigherThatAllowedErrLbl, NpRvVoucherType.Code);
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
