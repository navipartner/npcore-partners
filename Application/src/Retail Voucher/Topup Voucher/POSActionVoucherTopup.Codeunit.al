codeunit 6151023 "NPR POSAction: Voucher Top-up" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Apply Top-up (refill) on existing Retail Voucher.';
        AmountRetailVoucher_CptLbl: Label 'Enter Amount';
        DiscAmountRetailVoucher_CptLbl: Label 'Enter Discount Amount';
        DiscPercRetailVoucher_CptLbl: Label 'Enter Discount Percent';
        ParameterAmount_CaptionLbl: Label 'Amount';
        ParameterDiscAmount_CaptionLbl: Label 'Discount Amount';
        ParameterDiscType_CaptionLbl: Label 'Discount Type';
        ParameterDiscType_OptionCaptionLbl: Label 'Amount,Percent,None';
        ParameterDiscType_OptionsLbl: Label 'Amount,Percent,None', Locked = true;
        ParameterReferenceNo_CaptionLbl: Label 'Reference No.';
        ParameterShowVoucherCard_CaptionLbl: Label 'Show Voucher Card';
        ParameterVoucherType_CaptionLbl: Label 'Voucher Type Filter';
        ReferenceRetailVoucher_CptLbl: Label 'Enter Reference No.';
        ReferenceRetailVoucherTitleLbl: Label 'Top-up Retail Voucher';
        VoucherType: Label 'RETPARTIAL', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddDecimalParameter('Amount', 0, ParameterAmount_CaptionLbl, ParameterAmount_CaptionLbl);
        WorkflowConfig.AddDecimalParameter('DiscountAmount', 0, ParameterDiscAmount_CaptionLbl, ParameterDiscAmount_CaptionLbl);
        WorkflowConfig.AddOptionParameter(
            'DiscountType',
            ParameterDiscType_OptionsLbl,
#pragma warning disable AA0139
            SelectStr(3, ParameterDiscType_OptionsLbl),
#pragma warning restore AA0139
            ParameterDiscType_CaptionLbl,
            ParameterDiscType_CaptionLbl,
            ParameterDiscType_OptionCaptionLbl);
        WorkflowConfig.AddTextParameter('ReferenceNo', '', ParameterReferenceNo_CaptionLbl, ParameterReferenceNo_CaptionLbl);
        WorkflowConfig.AddBooleanParameter('ShowVoucherCard', true, ParameterShowVoucherCard_CaptionLbl, ParameterShowVoucherCard_CaptionLbl);
        WorkflowConfig.AddTextParameter('VoucherTypeFilter', VoucherType, ParameterVoucherType_CaptionLbl, ParameterVoucherType_CaptionLbl);

        WorkflowConfig.AddLabel('TopupVoucherTitle', ReferenceRetailVoucherTitleLbl);
        WorkflowConfig.AddLabel('ReferenceNo', ReferenceRetailVoucher_CptLbl);
        WorkflowConfig.AddLabel('Amount', AmountRetailVoucher_CptLbl);
        WorkflowConfig.AddLabel('DiscountAmount', DiscAmountRetailVoucher_CptLbl);
        WorkflowConfig.AddLabel('DiscountPercent', DiscPercRetailVoucher_CptLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTopUpVoucher.js###
'let main=async({workflow:l,parameters:u,popup:t,captions:e})=>{let o,i,n;if(u.ReferenceNo?o=u.ReferenceNo:o=await t.input({title:e.TopupVoucherTitle,caption:e.ReferenceNo,value:""}),o==null)return;const{VoucherNo:c}=await l.respond("validate_voucher",{referenceNo:o});if(!(c==null||c=="")){if(u.Amount<=0){if(i=await t.numpad({title:e.TopupVoucherTitle,caption:e.Amount,value:0,notBlank:!0}),i==null)return}else i=u.Amount;switch(u.DiscountType.toInt()){case u.DiscountType.Amount:if(u.DiscountAmount<=0){if(n=await t.numpad({title:e.TopupVoucherTitle,caption:e.DiscountAmount,value:0}),n==null)return}else n=u.DiscountAmount;break;case u.DiscountType.Percent:if(u.DiscountAmount<=0){if(n=await t.numpad({title:e.TopupVoucherTitle,caption:e.DiscountPercent,value:0}),n==null)return}else n=u.DiscountAmount;break;default:break}u.ShowVoucherCard&&await l.respond("show_voucher_card",{VoucherNo:c}),await l.respond("topup_voucher",{VoucherNo:c,amount:i,disc_amount:n})}};'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        FrontEnd.GetSession(POSSession);

        case Step of
            'validate_voucher':
                FrontEnd.WorkflowResponse(OnActionValidateVoucher(Context));
            'show_voucher_card':
                FrontEnd.WorkflowResponse(OnActionShowVoucherCard(Context));
            'topup_voucher':
                FrontEnd.WorkflowResponse(OnActionTopupVoucher(Context, POSSession));
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'VoucherTypeFilter' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        Handled := true;

        if Page.RunModal(0, NpRvVoucherType) = Action::LookupOK then
            POSParameterValue.Value := NpRvVoucherType.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateVoucherTypeCode(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'VoucherTypeFilter' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        NpRvVoucherType.SetFilter(Code, POSParameterValue.Value);
        NpRvVoucherType.FindFirst();
    end;

    local procedure OnActionValidateVoucher(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject;
    var
        POSActionTopupBL: Codeunit "NPR POS Act. Voucher Top-up-B";
        VoucherNo: Code[20];
        ReferenceNo: Text;
        VoucherTypeFilter: Text;
    begin
        VoucherTypeFilter := Context.GetStringParameter('VoucherTypeFilter');

        Context.SetScopeRoot();
        ReferenceNo := UpperCase(Context.GetString('referenceNo'));
        VoucherNo := POSActionTopupBL.FindVoucher(VoucherTypeFilter, ReferenceNo);

        Response.Add('VoucherNo', VoucherNo);
    end;

    local procedure OnActionShowVoucherCard(Context: Codeunit "NPR POS JSON Helper"): JsonObject;
    var
        POSActionTopupBL: Codeunit "NPR POS Act. Voucher Top-up-B";
        VoucherNo: Text;
    begin
        Context.SetScopeRoot();
        VoucherNo := Context.GetString('VoucherNo');
        POSActionTopupBL.RunVoucherCard(VoucherNo);
    end;

    local procedure OnActionTopupVoucher(Context: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session"): JsonObject;
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        AmtInput, DiscountAmount, DiscountPct : Decimal;
        DiscountType: Text;
        VoucherNo: Text;
    begin
        Context.SetScopeRoot();
        VoucherNo := Context.GetString('VoucherNo');
        Context.SetScopeRoot();
        AmtInput := Context.GetDecimal('amount');

        Context.SetScopeRoot();
        Context.SetScopeParameters();
        DiscountType := Context.GetString('DiscountType');
        case DiscountType of
            '0':
                begin
                    Context.SetScopeRoot();
                    DiscountAmount := Context.GetDecimal('disc_amount');
                end;
            '1':
                begin
                    Context.SetScopeRoot();
                    DiscountPct := Context.GetDecimal('disc_amount');
                end;
        end;

        NpRvVoucherMgt.TopUpVoucher(POSSession, VoucherNo, DiscountType, AmtInput, DiscountAmount, DiscountPct);
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::TOPUP_VOUCHER));
    end;
}
