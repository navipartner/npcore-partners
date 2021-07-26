codeunit 6014621 "NPR NpRvCheckVoucher"

{
    local procedure ActionCode(): Code[20]
    begin
        exit('CHECK_VOUCHER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescriptionLbl, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
              'let result = await popup.input({title: $captions.title, caption: $captions.referencenoprompt, required: true});' +
              'if (result === null) {' +
              '    return;' +
              '}' +
              'workflow.respond("", { ReferenceNo: result });'
            );
            Sender.RegisterTextParameter('VoucherTypeCode', '');
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'title', Title);
        Captions.AddActionCaption(ActionCode(), 'voucherprompt', ReferenceNoPrompt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        TooLongErr: Label '%1 cannot have more than %2 characters.';
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Text;
        VoucherTypeCode: Code[20];
        ReferenceNo: Text;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        NotFoundErr: Label 'Reference No. %1 and Voucher Type %2 not found';
        NpRvVoucherCard: Page "NPR NpRv Voucher Card";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;
        ReferenceNo := Context.GetStringOrFail('ReferenceNo', StrSubstNo(ReadingErr, 'OnAction', ActionCode(), 'ReferenceNo'));
        if StrLen(ReferenceNo) > 50 then
            Error(TooLongErr, 'ReferenceNo', 50);

        VoucherType := Context.GetStringParameter('VoucherTypeCode');
        if StrLen(VoucherType) > MaxStrLen(VoucherTypeCode) then
            Error(TooLongErr, 'VoucherTypeCode', 20)
        else
            VoucherTypeCode := VoucherType;

        if not NpRvVoucherMgt.FindVoucher(VoucherTypeCode, ReferenceNo, Voucher) then
            Error(NotFoundErr, ReferenceNo, VoucherTypeCode);


        NpRvVoucherCard.Editable(false);
        NpRvVoucherCard.SetRecord(Voucher);
        NpRvVoucherCard.RunModal();

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean);
    var
        VoucherTypeCode: Code[20];
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'VoucherTypeCode':
                begin
                    VoucherTypeCode := CopyStr(POSParameterValue.Value, 1, MaxStrLen(VoucherTypeCode));
                    if LookupVoucherTypeCode(VoucherTypeCode) then
                        POSParameterValue.Value := VoucherTypeCode;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        NpRvVoucherTypeLbl: Label '@%1*', Locked = true;
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'VoucherTypeCode':
                begin
                    if POSParameterValue.Value = '' then
                        exit;

                    NpRvVoucherType.Code := POSParameterValue.Value;
                    if not NpRvVoucherType.Find() then begin
                        NpRvVoucherType.SetFilter(Code, CopyStr(StrSubstNo(NpRvVoucherTypeLbl, POSParameterValue.Value), 1, MaxStrLen(NpRvVoucherType.Code)));
                        NpRvVoucherType.FindFirst();
                    end;
                    POSParameterValue.Value := NpRvVoucherType.Code;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        CaptionVoucherTypeCode: Label 'Voucher Type Code';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'VoucherTypeCode':
                Caption := CaptionVoucherTypeCode;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        VoucherTypeCodeLbl: Label 'Specifies Voucher Type Code.';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'VoucherTypeCode':
                Caption := VoucherTypeCodeLbl;
        end;
    end;

    local procedure LookupVoucherTypeCode(var VoucherTypeCode: Code[20]): Boolean
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin

        NpRvVoucherType.FilterGroup(0);
        if VoucherTypeCode <> '' then begin
            NpRvVoucherType.Code := VoucherTypeCode;
            if NpRvVoucherType.find('=><') then;
        end;
        if Page.RunModal(0, NpRvVoucherType) = Action::LookupOK then begin
            VoucherTypeCode := NpRvVoucherType.Code;
            exit(true);
        end;
        exit(false);
    end;

    var
        ActionDescriptionLbl: Label 'This action handles Retail Voucher Check.';
        Title: Label 'Retail Voucher Check';
        ReferenceNoPrompt: Label 'Voucher Reference Number';
        ReadingErr: Label 'reading in %1 of %2 string %3';
}
