codeunit 88012 "NPR BCPT Init Voucher Usage" implements "BCPT Test Param. Provider"
{

    SingleInstance = true;

    trigger OnRun();
    begin
        SelectLatestVersion();

        if not IsInitialized then begin
            InitTest();
            IsInitialized := true;
        end;

        InitializeData();
    end;

    var
        BCPTTestContext: Codeunit "BCPT Test Context";
        IsInitialized: Boolean;
        UnitPrice: Integer;
        UnitPriceParamLbl: Label 'UnitPrice', Locked = true;
        ParamValidationErr: Label 'Parameter is not defined in the correct format. The expected format is "%1"', Comment = '%1 - expected format';

    local procedure InitTest();
    begin
        if Evaluate(UnitPrice, BCPTTestContext.GetParameter(UnitPriceParamLbl)) then;

        if UnitPrice <= 0 then
            UnitPrice := 100;
    end;

    local procedure InitializeData()
    begin
        DeleteBCPTVouchers();
        PopulateBCPTVouchers('CREDITVOUCHER', UnitPrice);
    end;

    local procedure DeleteBCPTVouchers()
    var
        BCPTVoucher: Record "NPR BCPT Voucher";
    begin
        BCPTVoucher.DeleteAll();
    end;

    local procedure PopulateBCPTVouchers(VoucherTypeCode: Code[20]; ThisUnitPrice: Decimal)
    var
        Voucher: Record "NPR NpRv Voucher";
        BCPTVoucher: Record "NPR BCPT Voucher";
    begin
        Voucher.SetRange("Voucher Type", VoucherTypeCode);
        Voucher.SetFilter(Amount, '%1..', ThisUnitPrice);
        Voucher.SetRange("In-use Quantity", 0);
        if Voucher.FindSet() then
            repeat
                BCPTVoucher.Init();
                BCPTVoucher."Reference No." := Voucher."Reference No.";
                BCPTVoucher.Insert();
            until Voucher.Next() = 0;
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit(GetDefaultUnitPriceParameter());
    end;

    local procedure GetDefaultUnitPriceParameter(): Text[1000]
    begin
        exit(CopyStr(UnitPriceParamLbl + '=' + Format(100), 1, 1000));
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    begin
        ValidateUnitPriceParameter(CopyStr(SelectStr(1, Parameters), 1, 1000));
    end;

    local procedure ValidateUnitPriceParameter(Parameter: Text[1000])
    begin
        if StrPos(Parameter, UnitPriceParamLbl) > 0 then begin
            Parameter := DelStr(Parameter, 1, StrLen(UnitPriceParamLbl + '='));
            if Evaluate(UnitPrice, Parameter) then
                exit;
        end;
        Error(ParamValidationErr, GetDefaultUnitPriceParameter());
    end;
}
