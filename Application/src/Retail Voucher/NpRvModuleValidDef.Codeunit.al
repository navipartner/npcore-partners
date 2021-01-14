codeunit 6151015 "NPR NpRv Module Valid.: Def."
{
    var
        Text000: Label 'Validate Voucher - Default';
        Text001: Label 'Voucher is being used';
        Text002: Label 'Voucher has already been used';
        Text003: Label 'Voucher is not valid yet';
        Text004: Label 'Voucher is not valid anymore';
        Text005: Label 'Invalid Reference No. %1';

    procedure ValidateVoucher(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        Timestamp: DateTime;
    begin
        if not NpRvVoucherMgt.FindVoucher(NpRvVoucherBuffer."Voucher Type", NpRvVoucherBuffer."Reference No.", Voucher) then
            Error(Text005, NpRvVoucherBuffer."Reference No.");
        NpRvVoucherMgt.Voucher2Buffer(Voucher, NpRvVoucherBuffer);
        VoucherType.Get(NpRvVoucherBuffer."Voucher Type");
        VoucherType.TestField("Payment Type");
        if Voucher.CalcInUseQty() > 0 then
            Error(Text001);

        Voucher.CalcFields(Open);

        if not Voucher.Open then
            Error(Text002);

        Timestamp := CurrentDateTime;
        if Voucher."Starting Date" > Timestamp then
            Error(Text003);

        if (Voucher."Ending Date" < Timestamp) and (Voucher."Ending Date" <> 0DT) then
            Error(Text004);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NPR NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Validate Voucher", ModuleCode()) then
            exit;

        VoucherModule.Init;
        VoucherModule.Type := VoucherModule.Type::"Validate Voucher";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnHasValidateVoucherSetup', '', true, true)]
    local procedure OnHasValidateVoucherSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasValidateSetup: Boolean)
    begin
        if VoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;

        HasValidateSetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnSetupValidateVoucher', '', true, true)]
    local procedure OnSetupValidateVoucher(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
        if VoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunValidateVoucher', '', true, true)]
    local procedure OnRunValidateVoucher(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if NpRvVoucherBuffer."Validate Voucher Module" <> ModuleCode() then
            exit;

        ValidateVoucher(NpRvVoucherBuffer);
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

