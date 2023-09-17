codeunit 6014621 "NPR POSAction: CheckVoucher" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action handles Retail Voucher Check.';
        TitleLbl: Label 'Retail Voucher Check';
        ReferenceNoPromptLbl: Label 'Voucher Reference Number';
        VoucherTypeCodeCptlLbl: Label 'Voucher Type Code';
        VoucherTypeCodeDescLbl: Label 'Specifies Voucher Type Code.';
        TooLongErr: Label 'Reference No. cannot have more than 50 characters.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('title', TitleLbl);
        WorkflowConfig.AddLabel('referencenoprompt', ReferenceNoPromptLbl);
        WorkflowConfig.AddLabel('tooLongErr', TooLongErr);
        WorkflowConfig.AddTextParameter('VoucherTypeCode', '', VoucherTypeCodeCptlLbl, VoucherTypeCodeDescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'ProcessVoucher':
                FrontEnd.WorkflowResponse(ProcessVoucher(Context));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionCheckVoucher.js###
'let main=async({workflow:n,captions:r,popup:t})=>{let e=await t.input({title:r.title,caption:r.referencenoprompt,required:!0});if(!(e===null||e==="")){if(Object.keys(e).length>50){await t.error(r.tooLongErr);return}return await n.respond("ProcessVoucher",{ReferenceNo:e})}};'
        )
    end;

    local procedure ProcessVoucher(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        VoucherTypeCode: Code[20];
        ReferenceNo, VoucherType : Text;
        VoucherReferenceNumber: Text[50];
        POSActionCheckVoucherB: Codeunit "NPR POS Action:Check Voucher B";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        ReferenceNo := Context.GetString('ReferenceNo');
        VoucherType := Context.GetStringParameter('VoucherTypeCode');

        NpRvVoucherMgt.TrimTypeAndReference(VoucherType, VoucherTypeCode, ReferenceNo, VoucherReferenceNumber);

        POSActionCheckVoucherB.CheckVoucher(VoucherTypeCode, VoucherReferenceNumber);
        exit(Response);

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean);
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> 'CHECK_VOUCHER' then
            exit;

        case POSParameterValue.Name of
            'VoucherTypeCode':
                begin
                    if Page.RunModal(0, NpRvVoucherType) = Action::LookupOK then
                        POSParameterValue.Value := NpRvVoucherType.Code;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        ErrorMsg: Label 'POS Parameter value can''t be longer then voucher type code';
    begin
        if POSParameterValue."Action Code" <> 'CHECK_VOUCHER' then
            exit;

        case POSParameterValue.Name of
            'VoucherTypeCode':
                begin
                    if POSParameterValue.Value = '' then
                        exit;

                    if StrLen(POSParameterValue.Value) > MaxStrLen(NpRvVoucherType.Code) then
                        Error(ErrorMsg);

                    POSParameterValue.Value := UpperCase(POSParameterValue.Value);
                    if not NpRvVoucherType.Get(POSParameterValue.Value) then begin
                        NpRvVoucherType.SetFilter(Code, (StrSubstNo('%1*', POSParameterValue.Value)));
                        NpRvVoucherType.FindFirst();
                        POSParameterValue.Value := NpRvVoucherType.Code;
                    end;
                end;
        end;
    end;
}
