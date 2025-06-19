codeunit 6151015 "NPR NpRv Module Valid.: Def."
{
    Access = Internal;

    procedure ValidateVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ArchvoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        Voucher: Record "NPR NpRv Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VourcherRedeemedErr: Label 'The voucher with Reference No. %1 has already been redeemed in another transaction on %2.', Comment = '%1 - voucher reference number, 2% - date';
        InvalidReferenceErr: Label 'Invalid Reference No. %1', Comment = '%1 - Reference Number value';
    begin
        if not NpRvVoucherMgt.FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", Voucher) then begin
            if NpRvVoucherMgt.FindArchivedVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", ArchVoucher) then begin
                ArchvoucherEntry.SetCurrentKey("Arch. Voucher No.");
                ArchvoucherEntry.SetRange("Arch. Voucher No.", ArchVoucher."No.");
                if ArchvoucherEntry.FindLast() then;
                Error(VourcherRedeemedErr, TempNpRvVoucherBuffer."Reference No.", ArchvoucherEntry."Posting Date");
            end else
                Error(InvalidReferenceErr, TempNpRvVoucherBuffer."Reference No.");
        end;

        CheckVoucher(Voucher);
        NpRvVoucherMgt.Voucher2Buffer(Voucher, TempNpRvVoucherBuffer);
    end;

    local procedure CheckVoucher(var Voucher: Record "NPR NpRv Voucher")
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        IsHandled: Boolean;
        Timestamp: DateTime;
        VoucherAlreadyUsedErr: Label 'The voucher has already been used. No amount remains on the voucher.';
        VoucherBeingUsedErr: Label 'Voucher is being used.';
        VoucherNotValidAnymoreErr: Label 'Voucher is not valid anymore.';
        VoucherNotValidYetErr: Label 'Voucher is not valid yet.';
    begin
        OnBeforeCheckVoucher(Voucher, IsHandled);
        if IsHandled then
            exit;

        Timestamp := CurrentDateTime;
        if Voucher."Starting Date" > Timestamp then
            Error(VoucherNotValidYetErr);

        if (Voucher."Ending Date" < Timestamp) and (Voucher."Ending Date" <> 0DT) then
            Error(VoucherNotValidAnymoreErr);

        Voucher.CalcFields(Open);
        if not Voucher.Open then
            Error(VoucherAlreadyUsedErr);

        TestVoucherType(Voucher."Voucher Type");
        if not NpRvVoucherMgt.VoucherReservationByAmountFeatureEnabled() then begin
            if Voucher.CalcInUseQty() > 0 then
                Error(VoucherBeingUsedErr);
        end;
    end;

    local procedure TestVoucherType(VoucherTypeCode: Code[20])
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        VoucherType.Get(VoucherTypeCode);
        VoucherType.TestField("Payment Type");
    end;

    [Obsolete('Not being used.', '2023-06-28')]
    procedure FindVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NPR NpRv Voucher Module")
    var
        ValidateVoucherDefaultDescriptionLbl: Label 'Validate Voucher - Default';
    begin
        if VoucherModule.Get(VoucherModule.Type::"Validate Voucher", ModuleCode()) then
            exit;

        VoucherModule.Init();
        VoucherModule.Type := VoucherModule.Type::"Validate Voucher";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := ValidateVoucherDefaultDescriptionLbl;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnHasValidateVoucherSetup', '', true, true)]
    local procedure OnHasValidateVoucherSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasValidateSetup: Boolean)
    begin
        if VoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;

        HasValidateSetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnSetupValidateVoucher', '', true, true)]
    local procedure OnSetupValidateVoucher(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
        if VoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunValidateVoucher', '', true, true)]
    local procedure OnRunValidateVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if TempNpRvVoucherBuffer."Validate Voucher Module" <> ModuleCode() then
            exit;

        ValidateVoucher(TempNpRvVoucherBuffer);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckVoucher(var Voucher: Record "NPR NpRv Voucher"; var IsHandled: Boolean)
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRv Module Valid.: Def.");
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('DEFAULT');
    end;
}

