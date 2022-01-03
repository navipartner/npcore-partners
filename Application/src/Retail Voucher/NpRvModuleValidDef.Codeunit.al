codeunit 6151015 "NPR NpRv Module Valid.: Def."
{
    var
        Text000: Label 'Validate Voucher - Default';
        Text001: Label 'Voucher is being used';
        Text002: Label 'Voucher has already been used';
        Text003: Label 'Voucher is not valid yet';
        Text004: Label 'Voucher is not valid anymore';
        Text005: Label 'Invalid Reference No. %1';
        VourcherRedeemedErr: Label 'The voucher with Reference No. %1 has already been redeemed in another transaction on %2.', Comment = '%1 - voucher reference number, 2% - date';

    procedure ValidateVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ArchvoucherEntry: record "NPR NpRv Arch. Voucher Entry";
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        Timestamp: DateTime;
    begin
        if not NpRvVoucherMgt.FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", Voucher) then begin
            if NpRvVoucherMgt.FindArchivedVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", ArchVoucher) then begin
                ArchvoucherEntry.SetCurrentKey("Arch. Voucher No.");
                ArchvoucherEntry.SetRange("Arch. Voucher No.", ArchVoucher."No.");
                if ArchvoucherEntry.FindLast() then;
                Error(VourcherRedeemedErr, TempNpRvVoucherBuffer."Reference No.", ArchvoucherEntry."Posting Date");
            end else
                Error(Text005, TempNpRvVoucherBuffer."Reference No.");
        end;
        NpRvVoucherMgt.Voucher2Buffer(Voucher, TempNpRvVoucherBuffer);
        VoucherType.Get(TempNpRvVoucherBuffer."Voucher Type");
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

    procedure FindVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        Voucher: Record "NPR NpRv Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        if not NpRvVoucherMgt.FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", Voucher) then
            Error(Text005, TempNpRvVoucherBuffer."Reference No.");
        NpRvVoucherMgt.Voucher2Buffer(Voucher, TempNpRvVoucherBuffer);

        if not Voucher.Open then
            Error(Text002);

        if Voucher."Starting Date" > CurrentDateTime() then
            Error(Text003);

        if (Voucher."Ending Date" < CurrentDateTime()) and (Voucher."Ending Date" <> 0DT) then
            Error(Text004);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NPR NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Validate Voucher", ModuleCode()) then
            exit;

        VoucherModule.Init();
        VoucherModule.Type := VoucherModule.Type::"Validate Voucher";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
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

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRv Module Valid.: Def.");
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('DEFAULT');
    end;
}

