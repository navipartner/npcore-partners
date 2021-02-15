codeunit 85017 "NPR Library - Tax Free"
{
    procedure CreateTaxFreePosUnit(PosUnitNo: Code[10]; var TaxFreePosUnit: Record "NPR Tax Free POS Unit");
    begin
        TaxFreePosUnit.Init;
        TaxFreePosUnit.Validate(
          "Pos Unit No.", PosUnitNo);
        TaxFreePosUnit.Validate(Mode, TaxFreePosUnit.Mode::Test);
        TaxFreePosUnit."Check POS Terminal IIN" := true;
        TaxFreePosUnit.Insert();
    end;

    procedure AddHandlerTaxFreePosUnit(var TaxFreePosUnit: Record "NPR Tax Free POS Unit"; var TaxFreeService: Record "NPR Tax Free GB I2 Service"; var tmpHandlerParameter: Record "NPR Tax Free Handler Param."; TaxFreeHandlerID: Enum "NPR Tax Free Handler ID");
    begin
        TaxFreePosUnit.Get(TaxFreePosUnit."POS Unit No.");
        Clear(TaxFreePosUnit."Handler Parameters");
        TaxFreePosUnit.Validate("Handler ID Enum", TaxFreeHandlerID);
        TaxFreePosUnit.Modify();

        InitParametersTaxFree(TaxFreePosUnit, TaxFreeService, tmpHandlerParameter);
    end;

    procedure CreatePosUnitTaxFreeParameterGB(TaxFreePosUnit: Record "NPR Tax Free POS Unit"; var TaxFreeService: Record "NPR Tax Free GB I2 Service")
    var
        TaxFreePosUnitPrm: Record "NPR Tax Free GB I2 Param.";
    begin
        TaxFreePosUnitPrm.Init();
        TaxFreePosUnitPrm."Tax Free Unit" := TaxFreePosUnit."POS Unit No.";
        TaxFreePosUnitPrm.Validate("Shop ID", GenerateRandomCode(TaxFreePosUnitPrm.FieldNo("Shop ID"), DATABASE::"NPR Tax Free GB I2 Param."));
        TaxFreePosUnitPrm.Validate("Desk ID", GenerateRandomCode(TaxFreePosUnitPrm.FieldNo("Desk ID"), DATABASE::"NPR Tax Free GB I2 Param."));
        TaxFreePosUnitPrm.Validate("UserName", GenerateRandomCode(TaxFreePosUnitPrm.FieldNo("UserName"), DATABASE::"NPR Tax Free GB I2 Param."));
        TaxFreePosUnitPrm.Validate("Password", GenerateRandomCode(TaxFreePosUnitPrm.FieldNo("Password"), DATABASE::"NPR Tax Free GB I2 Param."));
        TaxFreePosUnitPrm."Date Last Auto Configured" := Today;
        if TaxFreePosUnitPrm.Insert() then;
        DeleteOldCreateNewTaxFreeService(TaxFreePosUnit, TaxFreeService);
    end;

    procedure InitParametersTaxFree(TaxFreePosUnit: Record "NPR Tax Free POS Unit"; var TaxFreeService: Record "NPR Tax Free GB I2 Service"; var tmpHandlerParameter: Record "NPR Tax Free Handler Param.")
    var
        TaxFreeGBI2: Codeunit "NPR Tax Free GB I2";
        NPRTaxFreePTFPI: Codeunit "NPR Tax Free PTF PI";
        GlobalBlueIINBlacklist: Record "NPR Tax Free GB IIN Blacklist";
    begin
        case true of
            TaxFreePosUnit."Handler ID Enum" = TaxFreePosUnit."Handler ID Enum"::GLOBALBLUE_I2:
                begin
                    CreatePosUnitTaxFreeParameterGB(TaxFreePosUnit, TaxFreeService);
                    GlobalBlueIINBlacklist.DeleteAll();
                    GlobalBlueIINBlacklist.Init();
                    GlobalBlueIINBlacklist."Shop Country Code" := 0;
                    GlobalBlueIINBlacklist."Range Inclusive Start" := 123456;
                    GlobalBlueIINBlacklist."Range Inclusive Start" := 123457;
                    GlobalBlueIINBlacklist.Insert();
                end;

            TaxFreePosUnit."Handler ID Enum" in [TaxFreePosUnit."Handler ID Enum"::PREMIER_PI]:
                DeleteAndCreatePosUnitTaxFreeParameterPFPI(TaxFreePosUnit, tmpHandlerParameter);
            else begin
                    Error('');
                end;
        end;
    end;

    procedure DeleteAndCreatePosUnitTaxFreeParameterPFPI(TaxFreePosUnit: Record "NPR Tax Free POS Unit"; var tmpHandlerParameter: Record "NPR Tax Free Handler Param.")
    begin
        AddParametersPTFPI(tmpHandlerParameter);
        AddRandomValue(tmpHandlerParameter);
        tmpHandlerParameter.SerializeParameterBLOB(TaxFreePosUnit);
        TaxFreePosUnit.Modify();
    end;

    local procedure AddRandomValue(var tmpHandlerParameter: Record "NPR Tax Free Handler Param.")
    begin
        if tmpHandlerParameter.FindSet() then
            repeat
                case tmpHandlerParameter."Data Type" of
                    tmpHandlerParameter."Data Type"::Integer:
                        tmpHandlerParameter.Value := Format(Random(1000));
                    tmpHandlerParameter."Data Type"::Decimal:
                        tmpHandlerParameter.Value := Format(GenerateRandomDec(999, 2));
                    tmpHandlerParameter."Data Type"::Text:
                        tmpHandlerParameter.Value := GenerateRandomCode(tmpHandlerParameter.FieldNo("Value"), DATABASE::"NPR Tax Free Handler Param.");
                end;
                tmpHandlerParameter.Modify();
            until tmpHandlerParameter.Next() = 0;
    end;

    local procedure AddParametersPTFPI(var tmpHandlerParameters: Record "NPR Tax Free Handler Param.")
    begin
        tmpHandlerParameters.AddParameter('Merchant ID', tmpHandlerParameters."Data Type"::Text);
        tmpHandlerParameters.AddParameter('VAT Number', tmpHandlerParameters."Data Type"::Text);
        tmpHandlerParameters.AddParameter('Country Code', tmpHandlerParameters."Data Type"::Integer);
        tmpHandlerParameters.AddParameter('Minimum Amount Limit', tmpHandlerParameters."Data Type"::Decimal);
    end;

    procedure DeleteOldCreateNewTaxFreeService(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var TaxFreeService: Record "NPR Tax Free GB I2 Service")
    begin
        TaxFreeService.SetRange("Tax Free Unit", TaxFreeUnit."POS Unit No.");
        TaxFreeService.DeleteAll();
        TaxFreeService.Init();
        TaxFreeService."Tax Free Unit" := TaxFreeUnit."POS Unit No.";
        TaxFreeService."Service ID" := Random(50);
        TaxFreeService."Minimum Purchase Amount" := GenerateRandomDec(999, 2);
        TaxFreeService."Maximum Purchase Amount" := GenerateRandomDecBetween(9999, TaxFreeService."Minimum Purchase Amount", 2);
        TaxFreeService."Void Limit In Days" := Random(30);
        TaxFreeService.Insert();
    end;

    procedure IssueVoucherResponseGB(var TaxFreeRequest: Record "NPR Tax Free Request"; IsSuccess: Boolean)
    begin
        TaxFreeRequest."External Voucher No." := GenerateRandomCode(TaxFreeRequest.FieldNo("External Voucher No."), Database::"NPR Tax Free Request");
        TaxFreeRequest."External Voucher Barcode" := GenerateRandomCode(TaxFreeRequest.FieldNo("External Voucher Barcode"), Database::"NPR Tax Free Request");
        TaxFreeRequest."Total Amount Incl. VAT" := 0;
        TaxFreeRequest."Refund Amount" := 0;
        TaxFreeRequest."Print Type" := TaxFreeRequest."Print Type"::PDF;
        TaxFreeRequest.Success := IsSuccess;
    end;

    procedure GenerateRandomCode(FieldNo: Integer; TableNo: Integer): Text
    begin
        exit(CopyStr(
                  LibraryUtility.GenerateRandomCode(FieldNo, TableNo), 1,
                  LibraryUtility.GetFieldLength(TableNo, FieldNo)));
    end;

    procedure GenerateRandomDecBetween(MaxNo: Decimal; MinNo: Decimal; MaxDecNo: Integer) GeneratedNumber: Decimal
    var
        GeneratedMax: Decimal;
        GeneratedMin: Decimal;
        RoundingPrec: Decimal;
        i: Integer;
    begin
        RoundingPrec := 1;
        for i := 1 to MaxDecNo do
            RoundingPrec /= 10;
        MaxNo := round(MaxNo, RoundingPrec, '=');
        MinNo := round(MinNo, RoundingPrec, '=');

        while GeneratedNumber < MinNo do
            GeneratedNumber := GenerateRandomDec(MaxNo, MaxDecNo);

    end;

    procedure GenerateRandomDec(MaxNo: Decimal; MaxDecNo: Integer): Decimal
    var
        i: Integer;
        RandDec: Integer;
        Divider: Integer;
        Decimals: Decimal;
    begin
        for i := 1 to MaxDecNo do
            if i = 1 then begin
                RandDec := 9;
                Divider := 10;
            end else begin
                RandDec := (RandDec * 10) + 9;
                Divider *= 10;
            end;
        Decimals := Random(RandDec) / Divider;

        exit(Random(Round(MaxNo, 1, '=')) - Decimals);
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
}
