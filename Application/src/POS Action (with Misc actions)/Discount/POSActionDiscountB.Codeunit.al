codeunit 6151142 "NPR POS Action - Discount B"
{
    Access = Internal;

    var
        DiscountAmountErr: Label 'Total discount amount entered must be less than the Sale Total!';
        DiscountPercentError: Label 'Discount percentage must be between 0 and 100.';
        Text005: Label 'Unit Price may not be changed when Line Type is %1';
        WrongDimensionValueErr: Label 'The dimension value %1 has not been set up for dimension %2.';
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
        MultiLineDiscTarget: Option " ","Positive Only","Negative Only","Non-Zero";
        SelectDiscountTargetLbl: Label 'Please select discount target lines:';
        DiscTargetAllOptionLbl: Label 'All non-zero quantity lines';
        AddDimensionCode: Code[20];
        AddDimensionValueCode: Code[20];
        ApprovedBySalespersonCode: Code[20];
        DiscountReasonCode: Code[10];
        DiscTargetOtherOptionsLbl: Label 'Positive quantity lines only,Negative quantity lines only';
        DiscountGroupFilter: Text;
        NoDiscTargetFound: Label 'System couldn''t find lines the discount to be applied to.\The POS action is preset for discounts to be applied to %1.';

    internal procedure GetReasonCode(LookupReasonCode: Boolean; ReasonCodeMandatory: Boolean; var ReasonCode: Code[10])
    var
        ReasonCodeRecord: Record "Reason Code";
        ReasonCodeMandatoryErr: Label 'Reason Code is mandatory for this discount';
    begin
        if LookupReasonCode or ReasonCodeMandatory then
            if Page.RunModal(0, ReasonCodeRecord) <> ACTION::LookupOK then begin
                if ReasonCodeMandatory then
                    Error(ReasonCodeMandatoryErr);
                exit;
            end;
        ReasonCode := ReasonCodeRecord.Code;
    end;

    internal procedure GetDimensionValue(DimensionCodeParameter: Text; var DimensionValueParameter: Text)
    var
        DimensionValue: Record "Dimension Value";
        DimMgt: Codeunit DimensionManagement;
    begin
        DimensionValue.SetRange("Dimension Code", DimensionCodeParameter);
        if PAGE.RunModal(0, DimensionValue) <> ACTION::LookupOK then
            exit;

        if not DimMgt.CheckDimValue(DimensionValue."Dimension Code", DimensionValue.Code) then
            Error(DimMgt.GetDimErr());
#pragma warning disable AA0139
        DimensionValueParameter := DimensionValue.Code;
#pragma warning restore
    end;

    internal procedure CheckNegativeAmount(DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra; InputValue: decimal)
    var
        NegativeAmtErr: Label 'Negative amount is not allowed. Please specify a positive figure.';
    begin
        if (InputValue < 0) and (DiscountType in [DiscountType::TotalAmount,
        DiscountType::TotalDiscountAmount,
        DiscountType::LineAmount,
        DiscountType::LineDiscountAmount]) then
            Error(NegativeAmtErr);
    end;

    internal procedure ProcessRequest(DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra; InputValue: decimal; var SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; PresetMultiLineDiscTarget: Integer)
    var
        TotalPrice: Decimal;
    begin
        if DiscountType in
          [DiscountType::TotalAmount,
           DiscountType::TotalDiscountAmount,
           DiscountType::DiscountPercentABS,
           DiscountType::DiscountPercentREL,
           DiscountType::DiscountPercentExtra,
           DiscountType::ClearTotalDiscount]
       then
            GetMultiLineDiscountTarget(
              SalePOS, SaleLinePOS,
              PresetMultiLineDiscTarget,
              not (DiscountType in [DiscountType::TotalAmount, DiscountType::TotalDiscountAmount]));

        case DiscountType of
            DiscountType::TotalAmount,
            DiscountType::TotalDiscountAmount,
            DiscountType::LineAmount,
            DiscountType::LineDiscountAmount:
                begin
                    if DiscountType in [DiscountType::TotalAmount, DiscountType::TotalDiscountAmount] then
                        TotalPrice := GetLinesTotalDiscountableValue(SalePOS)
                    else
                        TotalPrice := GetSingleLineTotalDiscountableValue(SaleLinePOS, false);
                    if (TotalPrice < InputValue) then
                        Error(DiscountAmountErr);
                end;

            DiscountType::DiscountPercentABS,
            DiscountType::DiscountPercentREL,
            DiscountType::LineDiscountPercentABS,
            DiscountType::LineDiscountPercentREL,
            DiscountType::DiscountPercentExtra,
            DiscountType::LineDiscountPercentExtra:
                begin
                    if (InputValue < 0) or (InputValue > 100) then
                        Error(DiscountPercentError);
                end;
        end;

        FinishRequest(DiscountType, InputValue, SalePOS, SaleLinePOS);
    end;


    internal procedure GetMultiLineDiscountTarget(var SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask; AllowAllLines: Boolean)
    var
        DefaultOptionNo: Integer;
        NoOfNegativeLines: Integer;
        NoOfPositiveLines: Integer;
        SelectedOptionNo: Integer;
        RequestMsgTxt: Text;
    begin
        if PresetMultiLineDiscTarget = PresetMultiLineDiscTarget::All then begin
            MultiLineDiscTarget := MultiLineDiscTarget::"Non-Zero";
            exit;
        end;

        MultiLineDiscTarget := MultiLineDiscTarget::"Positive Only";
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        NoOfPositiveLines := SaleLinePOS.Count();

        MultiLineDiscTarget := MultiLineDiscTarget::"Negative Only";
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        NoOfNegativeLines := SaleLinePOS.Count();

        if PresetMultiLineDiscTarget in [PresetMultiLineDiscTarget::"Positive Only", PresetMultiLineDiscTarget::"Negative Only"] then begin
            MultiLineDiscTarget := PresetMultiLineDiscTarget;
            if ((MultiLineDiscTarget = MultiLineDiscTarget::"Positive Only") and (NoOfPositiveLines = 0)) or
               ((MultiLineDiscTarget = MultiLineDiscTarget::"Negative Only") and (NoOfNegativeLines = 0))
            then
                Error(NoDiscTargetFound, LowerCase(SelectStr(MultiLineDiscTarget, DiscTargetOtherOptionsLbl)));
            exit;
        end;

        case true of
            (NoOfNegativeLines = 0) and (NoOfPositiveLines = 0):
                MultiLineDiscTarget := MultiLineDiscTarget::"Non-Zero";

            (NoOfNegativeLines <> 0) xor (NoOfPositiveLines <> 0):
                if NoOfPositiveLines <> 0 then
                    MultiLineDiscTarget := MultiLineDiscTarget::"Positive Only"
                else
                    MultiLineDiscTarget := MultiLineDiscTarget::"Negative Only";

            PresetMultiLineDiscTarget = PresetMultiLineDiscTarget::Auto:
                if SaleLinePOS.Quantity >= 0 then
                    MultiLineDiscTarget := MultiLineDiscTarget::"Positive Only"
                else
                    MultiLineDiscTarget := MultiLineDiscTarget::"Negative Only";

            else begin
                RequestMsgTxt := DiscTargetOtherOptionsLbl;
                if AllowAllLines then
                    RequestMsgTxt := RequestMsgTxt + ',' + DiscTargetAllOptionLbl;
                if SaleLinePOS.Quantity >= 0 then
                    DefaultOptionNo := 1
                else
                    DefaultOptionNo := 2;
                SelectedOptionNo := StrMenu(RequestMsgTxt, DefaultOptionNo, SelectDiscountTargetLbl);
                if SelectedOptionNo = 0 then
                    Error('');
                MultiLineDiscTarget := SelectedOptionNo;
            end;
        end;
    end;

    internal procedure FinishRequest(DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra; InputValue: decimal; var SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        case DiscountType of
            DiscountType::TotalAmount:
                SetTotalAmount(SalePOS, InputValue);
            DiscountType::TotalDiscountAmount:
                SetTotalDiscountAmount(SalePOS, InputValue);
            DiscountType::DiscountPercentABS:
                SetDiscountPctABS(SalePOS, InputValue);
            DiscountType::DiscountPercentREL:
                SetDiscountPctREL(SalePOS, InputValue);
            DiscountType::LineAmount:
                SetLineAmount(SaleLinePOS, InputValue);
            DiscountType::LineDiscountAmount:
                SetLineDiscountAmount(SaleLinePOS, InputValue);
            DiscountType::LineDiscountPercentABS:
                SetLineDiscountPctABS(SaleLinePOS, InputValue);
            DiscountType::LineDiscountPercentREL:
                SetLineDiscountPctREL(SaleLinePOS, InputValue);
            DiscountType::LineUnitPrice:
                SetLineUnitPrice(SaleLinePOS, InputValue);
            DiscountType::ClearLineDiscount:
                SetLineDiscountAmount(SaleLinePOS, 0);
            DiscountType::ClearTotalDiscount:
                SetTotalDiscountAmount(SalePOS, 0);
            DiscountType::DiscountPercentExtra:
                SetDiscountPctExtra(SalePOS, InputValue);
            DiscountType::LineDiscountPercentExtra:
                SetLineDiscountPctExtra(SaleLinePOS, InputValue);
        end;
    end;

    #region Locals
    local procedure ApplyDiscountOnLines(var SalePOS: Record "NPR POS Sale"; DiscountType: Option DiscountAmt,DiscountPct,LineAmt; Discount: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        AdjustedDiscountAmt: Decimal;
        RoundingRemainder: Decimal;
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        if not SaleLinePOS.FindSet() then
            exit;

        repeat
            ApplyDiscountOnLine(SaleLinePOS, DiscountType, Discount);
            if DiscountType = DiscountType::DiscountPct then begin
                AdjustedDiscountAmt := SaleLinePOS.Quantity * SaleLinePOS."Unit Price" * Discount / 100 + RoundingRemainder;
                if SaleLinePOS."Discount Amount" <> Round(AdjustedDiscountAmt) then
                    SetLineDiscountAmount(SaleLinePOS, Round(AdjustedDiscountAmt), true);
                RoundingRemainder := AdjustedDiscountAmt - SaleLinePOS."Discount Amount";
            end;
        until SaleLinePOS.Next() = 0;
    end;

    local procedure ApplyDiscountOnLine(var SaleLinePOS: Record "NPR POS Sale Line"; DiscountType: Option DiscountAmt,DiscountPct,LineAmt; InputValue: Decimal)
    begin
        ApplyDiscountOnLine(SaleLinePOS, DiscountType, InputValue, false);
    end;

    local procedure ApplyDiscountOnLine(var SaleLinePOS: Record "NPR POS Sale Line"; DiscountType: Option DiscountAmt,DiscountPct,LineAmt; InputValue: Decimal; SkipAjmts: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        xSaleLine: Record "NPR POS Sale Line";
        TotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        if SaleLinePOS."Custom Disc Blocked" then
            exit;
        if (DiscountType in [DiscountType::DiscountAmt, DiscountType::LineAmt]) and not SkipAjmts then begin
            InputValue := InputValue * GetSignFactor(SaleLinePOS);
            AdjustAmountForVat(SaleLinePOS, InputValue);
        end;

        xSaleLine := SaleLinePOS;

        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::" ";
        SaleLinePOS."Discount Code" := '';
        if InputValue <> 0 then
            SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;

        case DiscountType of
            DiscountType::DiscountAmt:
                begin
                    SaleLinePOS."Discount %" := 0;
                    SaleLinePOS."Discount Amount" := InputValue;
                end;
            DiscountType::DiscountPct:
                begin
                    if InputValue < 0 then
                        InputValue := 0;
                    if InputValue > 100 then
                        InputValue := 100;
                    SaleLinePOS."Discount %" := InputValue;
                    SaleLinePOS."Discount Amount" := 0;
                end;
            DiscountType::LineAmt:
                begin
                    SaleLinePOS."Discount %" := 0;
                    SaleLinePOS."Discount Amount" := SaleLinePOS."Unit Price" * SaleLinePOS.Quantity - InputValue;
                end;
        end;

        ApplyAdditionalParams(SaleLinePOS);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if Format(xSaleLine) <> Format(SaleLinePOS) then begin
            TotalDiscountManagement.TestBenefitItem(SaleLinePOS);
            SaleLinePOS.Modify();

            SalePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
            TotalDiscountManagement.CleanTotalDiscountFromSale(SalePOS, SaleLinePOS);
        end;
    end;

    local procedure ApplyFilterOnLines(var SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        UnexpectedFilterType: Label 'Unexpected quantity type filter. This is a critical programming error. Please contact system vendor.';
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        case MultiLineDiscTarget of
            MultiLineDiscTarget::" ":
                Error(UnexpectedFilterType);
            MultiLineDiscTarget::"Non-Zero":
                SaleLinePOS.SetFilter(Quantity, '<>%1', 0);
            MultiLineDiscTarget::"Negative Only":
                SaleLinePOS.SetFilter(Quantity, '<%1', 0);
            MultiLineDiscTarget::"Positive Only":
                SaleLinePOS.SetFilter(Quantity, '>%1', 0);
        end;
        SaleLinePOS.SetRange("Custom Disc Blocked", false);

        if DiscountGroupFilter > '' then
            SaleLinePOS.SetFilter("Item Disc. Group", DiscountGroupFilter);
    end;

    local procedure GetLinesTotalDiscountableValue(var SalePOS: Record "NPR POS Sale") TotalLineValue: Decimal
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);

        if SaleLinePOS.FindSet() then
            repeat
                TotalLineValue += GetSingleLineTotalDiscountableValue(SaleLinePOS, false);
            until SaleLinePOS.Next() = 0;

    end;

    local procedure GetSingleLineTotalDiscountableValue(SaleLinePOS: Record "NPR POS Sale Line"; IncludeDiscount: Boolean) LineValue: Decimal
    begin
        if not IncludeDiscount then
            SaleLinePOS."Discount Amount" := 0;

        if not SaleLinePOS."Custom Disc Blocked" then
            LineValue := SaleLinePOS.Quantity * SaleLinePOS."Unit Price" - SaleLinePOS."Discount Amount"
        else begin
            if SaleLinePOS."Price Includes VAT" then
                LineValue := SaleLinePOS."Amount Including VAT"
            else
                LineValue := SaleLinePOS.Amount;
        end;

        if SaleLinePOS."Price Includes VAT" and (InputIncludesTax = InputIncludesTax::Never) then
            LineValue := Round(LineValue / (1 + SaleLinePOS."VAT %" / 100))
        else
            if not SaleLinePOS."Price Includes VAT" and (InputIncludesTax = InputIncludesTax::Always) then
                LineValue := Round(LineValue * (1 + SaleLinePOS."VAT %" / 100));

        if SaleLinePOS.Quantity < 0 then
            LineValue := -LineValue;
    end;

    internal procedure SetTotalDiscountAmount(var SalePOS: Record "NPR POS Sale"; TotalDiscountAmount: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TotalPrice: Decimal;
        DiscountPct: Decimal;
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);

        TotalPrice := GetLinesTotalDiscountableValue(SalePOS);
        DiscountPct := TotalDiscountAmount / TotalPrice * 100;

        ApplyDiscountOnLines(SalePOS, "DiscType.DiscountPct"(), DiscountPct);

        AdjustRoundingForTotalAmountDiscount(SalePOS, (TotalPrice - TotalDiscountAmount));
    end;

    local procedure SetTotalAmount(var SalePOS: Record "NPR POS Sale"; Amount: Decimal)
    var
        t001: Label 'Total Amount entered must be less than the Sale Total!';
        DiscountPct: Decimal;
        TotalPrice: Decimal;
    begin
        TotalPrice := GetLinesTotalDiscountableValue(SalePOS);
        DiscountPct := (TotalPrice - Amount) / TotalPrice * 100;
        if DiscountPct < 0 then
            Error(t001);

        ApplyDiscountOnLines(SalePOS, "DiscType.DiscountPct"(), DiscountPct);

        AdjustRoundingForTotalAmountDiscount(SalePOS, Amount);
    end;

    local procedure SetDiscountPctABS(SalePOS: Record "NPR POS Sale"; DiscountPct: Decimal)
    begin
        ApplyDiscountOnLines(SalePOS, "DiscType.DiscountPct"(), DiscountPct);
    end;

    local procedure SetDiscountPctREL(SalePOS: Record "NPR POS Sale"; DiscountPct: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        RelativeDiscountPct: Decimal;
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        if not SaleLinePOS.FindSet() then
            exit;

        repeat
            RelativeDiscountPct := (1 - (1 - SaleLinePOS."Discount %" / 100) * (1 - DiscountPct / 100)) * 100;
            ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct"(), RelativeDiscountPct);
        until SaleLinePOS.Next() = 0;
    end;

    local procedure SetDiscountPctExtra(SalePOS: Record "NPR POS Sale"; ExtraDiscountPct: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NewDiscountPct: Decimal;
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        if not SaleLinePOS.FindSet() then
            exit;

        repeat
            NewDiscountPct := SaleLinePOS."Discount %" + ExtraDiscountPct;
            ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct"(), NewDiscountPct);
        until SaleLinePOS.Next() = 0;
    end;

    procedure SetLineAmount(var SaleLinePOS: Record "NPR POS Sale Line"; LineAmount: Decimal)
    begin
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.LineAmt"(), LineAmount);
    end;

    local procedure SetLineDiscountAmount(var SaleLinePOS: Record "NPR POS Sale Line"; DiscountAmount: Decimal)
    begin
        SetLineDiscountAmount(SaleLinePOS, DiscountAmount, false);
    end;

    local procedure SetLineDiscountAmount(var SaleLinePOS: Record "NPR POS Sale Line"; DiscountAmount: Decimal; SkipAjmts: Boolean)
    begin
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountAmt"(), DiscountAmount, SkipAjmts);
    end;

    internal procedure SetLineDiscountPctABS(var SaleLinePOS: Record "NPR POS Sale Line"; DiscountPct: Decimal)
    begin
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct"(), DiscountPct);
    end;

    local procedure SetLineDiscountPctREL(var SaleLinePOS: Record "NPR POS Sale Line"; DiscountPct: Decimal)
    var
        RelativeDiscountPct: Decimal;
    begin
        RelativeDiscountPct := (1 - (1 - SaleLinePOS."Discount %" / 100) * (1 - DiscountPct / 100)) * 100;
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct"(), RelativeDiscountPct);
    end;

    local procedure SetLineDiscountPctExtra(var SaleLinePOS: Record "NPR POS Sale Line"; ExtraDiscountPct: Decimal)
    var
        NewDiscountPct: Decimal;
    begin
        NewDiscountPct := SaleLinePOS."Discount %" + ExtraDiscountPct;
        ApplyDiscountOnLine(SaleLinePOS, "DiscType.DiscountPct"(), NewDiscountPct);
    end;

    local procedure SetLineUnitPrice(var SaleLinePOS: Record "NPR POS Sale Line"; UnitPrice: Decimal)
    var
        PrevRec: Text;
    begin
        if SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::"POS Payment", SaleLinePOS."Line Type"::"GL Payment", SaleLinePOS."Line Type"::Comment] then
            Error(Text005, SaleLinePOS."Line Type");
        PrevRec := Format(SaleLinePOS);

        SaleLinePOS."Unit Price" := UnitPrice;
        SaleLinePOS."Custom Price" := true;
        ApplyAdditionalParams(SaleLinePOS);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if PrevRec <> Format(SaleLinePOS) then
            SaleLinePOS.Modify();
    end;

    local procedure AdjustAmountForVat(SaleLinePOS: Record "NPR POS Sale Line"; var UserInputAmount: Decimal)
    begin
        if (InputIncludesTax = InputIncludesTax::IfPricesInclTax) or
           (SaleLinePOS."VAT %" = 0)
        then
            exit;

        if SaleLinePOS."Price Includes VAT" and (InputIncludesTax = InputIncludesTax::Never) then
            UserInputAmount := Round(UserInputAmount * (1 + SaleLinePOS."VAT %" / 100))
        else
            if not SaleLinePOS."Price Includes VAT" and (InputIncludesTax = InputIncludesTax::Always) then
                UserInputAmount := Round(UserInputAmount / (1 + SaleLinePOS."VAT %" / 100));
    end;

    local procedure AdjustRoundingForTotalAmountDiscount(var SalePOS: Record "NPR POS Sale"; Amount: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TotalLineValue: Decimal;
        RoundingAmt: Decimal;
    begin
        ApplyFilterOnLines(SalePOS, SaleLinePOS);
        if (SaleLinePOS.FindSet()) then begin
            repeat
                TotalLineValue += GetSingleLineTotalDiscountableValue(SaleLinePOS, true);
            until (SaleLinePOS.Next() = 0);

            RoundingAmt := TotalLineValue - Amount;
            if RoundingAmt <> 0 then begin
                AdjustAmountForVat(SaleLinePOS, RoundingAmt);
                SetLineDiscountAmount(SaleLinePOS, SaleLinePOS."Discount Amount" + RoundingAmt, true);
            end;
        end;
    end;

    local procedure AddDimensionToDimensionSet(var SaleLinePOS: Record "NPR POS Sale Line"; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, SaleLinePOS."Dimension Set ID");
        ValidateDimValue(DimensionCode, DimensionValueCode);
        UpdateDimensionSet(TempDimensionSetEntry, DimensionCode, DimensionValueCode);

        SaleLinePOS."Dimension Set ID" := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
        DimensionManagement.UpdateGlobalDimFromDimSetID(SaleLinePOS."Dimension Set ID", SaleLinePOS."Shortcut Dimension 1 Code", SaleLinePOS."Shortcut Dimension 2 Code");
    end;

    local procedure UpdateDimensionSet(var DimensionSetEntry: Record "Dimension Set Entry"; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    var
        DimensionValue: Record "Dimension Value";
    begin
        if DimensionSetEntry.Get(DimensionSetEntry."Dimension Set ID", DimensionCode) then begin
            if not ((DimensionSetEntry."Dimension Value Code" <> DimensionValueCode) or (DimensionValueCode = '')) then
                exit;

            DimensionSetEntry.Delete();
        end;

        if DimensionValueCode <> '' then begin
            DimensionValue.Get(DimensionCode, DimensionValueCode);

            DimensionSetEntry."Dimension Set ID" := DimensionSetEntry."Dimension Set ID";
            DimensionSetEntry."Dimension Code" := DimensionCode;
            DimensionSetEntry."Dimension Value Code" := DimensionValueCode;
            DimensionSetEntry."Dimension Value ID" := DimensionValue."Dimension Value ID";

            DimensionSetEntry.Insert();
        end;
    end;

    local procedure ValidateDimValue(DimCode: Code[20]; var DimValueCode: Code[20]): Boolean
    var
        DimValue: Record "Dimension Value";
    begin
        if DimValueCode = '' then
            exit;

        DimValue."Dimension Code" := DimCode;
        DimValue.Code := DimValueCode;
        DimValue.Find('=><');
        if DimValueCode <> CopyStr(DimValue.Code, 1, StrLen(DimValueCode)) then
            Error(WrongDimensionValueErr, DimValueCode, DimCode);
        DimValueCode := DimValue.Code;
    end;

    local procedure GetSignFactor(SaleLinePOS: Record "NPR POS Sale Line"): Integer
    begin
        if SaleLinePOS.Quantity < 0 then
            exit(-1);
        exit(1);
    end;

    internal procedure ApplyAdditionalParams(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        if ApprovedBySalespersonCode <> '' then
            SaleLinePOS."Discount Authorised by" := ApprovedBySalespersonCode;
        if DiscountReasonCode <> '' then
            SaleLinePOS."Reason Code" := DiscountReasonCode;
        if (AddDimensionCode <> '') and (AddDimensionValueCode <> '') then
            AddDimensionToDimensionSet(SaleLinePOS, AddDimensionCode, AddDimensionValueCode);
    end;

    internal procedure StoreAdditionalParams(ApprovedBySalesperson: Code[20]; DiscountReason: Code[10]; DimensionCode: Code[20]; DimensionValueCode: code[20]; DiscountGrpFilter: Text; InputIncludesTaxInt: Integer)
    begin
        ApprovedBySalespersonCode := ApprovedBySalesperson;
        DiscountReasonCode := DiscountReason;
        AddDimensionCode := DimensionCode;
        AddDimensionValueCode := DimensionValueCode;
        InputIncludesTax := InputIncludesTaxInt;
        DiscountGroupFilter := DiscountGrpFilter;
    end;
    #endregion
    #region Constants

# pragma warning disable AA0228
    local procedure "DiscType.DiscountAmt"(): Integer
    begin
        exit(0);
    end;

    local procedure "DiscType.DiscountPct"(): Integer
    begin
        exit(1);
    end;

    local procedure "DiscType.LineAmt"(): Integer
    begin
        exit(2);
    end;
# pragma warning restore

    #endregion
}
