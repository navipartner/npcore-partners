codeunit 6151015 "NpRv Module Validate - Default"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Replaced direct check on Voucher."In-Use Quantity" with CalcInUseQty
    // NPR5.49/MHA /20190228  CASE 342811 Signature changed on function OnRunValidateVoucher()


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Validate Voucher - Default';
        Text001: Label 'Voucher is being used';
        Text002: Label 'Voucher has already been used';
        Text003: Label 'Voucher is not valid yet';
        Text004: Label 'Voucher is not valid anymore';
        Text005: Label 'Invalid Reference No. %1';

    procedure ValidateVoucher(var NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary)
    var
        Voucher: Record "NpRv Voucher";
        VoucherType: Record "NpRv Voucher Type";
        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
        Timestamp: DateTime;
    begin
        //-NPR5.49 [342811]
        //Voucher.TESTFIELD("Voucher Type",VoucherType.Code);
        if not NpRvVoucherMgt.FindVoucher(NpRvVoucherBuffer."Voucher Type",NpRvVoucherBuffer."Reference No.",Voucher) then
          Error(Text005,NpRvVoucherBuffer."Reference No.");
        NpRvVoucherMgt.Voucher2Buffer(Voucher,NpRvVoucherBuffer);
        VoucherType.Get(NpRvVoucherBuffer."Voucher Type");
        //+NPR5.49 [342811]
        VoucherType.TestField("Payment Type");
        //-NPR5.48 [302179]
        //Voucher.CALCFIELDS("In-use Quantity",Open);
        //
        // IF Voucher."In-use Quantity" > 0 THEN
        //  ERROR(Text001);
        if Voucher.CalcInUseQty() > 0 then
          Error(Text001);

        Voucher.CalcFields(Open);
        //+NPR5.48 [302179]

        if not Voucher.Open then
          Error(Text002);

        Timestamp := CurrentDateTime;
        if Voucher."Starting Date" >  Timestamp then
          Error(Text003);

        if (Voucher."Ending Date" < Timestamp) and (Voucher."Ending Date" <> 0DT) then
          Error(Text004);
    end;

    local procedure "--- Voucher Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Validate Voucher",ModuleCode()) then
          exit;

        VoucherModule.Init;
        VoucherModule.Type := VoucherModule.Type::"Validate Voucher";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnHasValidateVoucherSetup', '', true, true)]
    local procedure OnHasValidateVoucherSetup(VoucherType: Record "NpRv Voucher Type";var HasValidateSetup: Boolean)
    begin
        //-NPR5.49 [342811]
        // IF NOT IsSubscriber(VoucherType) THEN
        //  EXIT;
        if VoucherType."Validate Voucher Module" <> ModuleCode() then
          exit;
        //+NPR5.49 [342811]

        HasValidateSetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnSetupValidateVoucher', '', true, true)]
    local procedure OnSetupValidateVoucher(var VoucherType: Record "NpRv Voucher Type")
    begin
        //-NPR5.49 [342811]
        // IF NOT IsSubscriber(VoucherType) THEN
        //  EXIT;
        if VoucherType."Validate Voucher Module" <> ModuleCode() then
          exit;
        //+NPR5.49 [342811]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunValidateVoucher', '', true, true)]
    local procedure OnRunValidateVoucher(var NpRvVoucherBuffer: Record "NpRv Voucher Buffer";var Handled: Boolean)
    begin
        if Handled then
          exit;
        //-NPR5.49 [342811]
        // IF NOT IsSubscriber(VoucherType) THEN
        //  EXIT;
        //
        // Handled := TRUE;
        //
        // ValidateVoucher(SalePOS,VoucherType,Voucher);
        if NpRvVoucherBuffer."Validate Voucher Module" <> ModuleCode() then
          exit;

        ValidateVoucher(NpRvVoucherBuffer);
        //+NPR5.49 [342811]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpRv Module Validate - Default");
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('DEFAULT');
    end;
}

