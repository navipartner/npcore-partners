#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151118 "NPR EcomCreateCouponImpl"
{
    Access = Internal;

    internal procedure Process(var EcomSalesLine: Record "NPR Ecom Sales Line"): Boolean
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        CouponTypes: List of [Code[20]];
    begin
        EcomSalesHeader.Get(EcomSalesLine."Document Entry No.");
        EcomSalesLine.ReadIsolation := EcomSalesLine.ReadIsolation::UpdLock;
        EcomSalesLine.Get(EcomSalesLine.RecordId());
        CheckIfLineCanBeProcessed(EcomSalesHeader, EcomSalesLine, CouponTypes);
        IssueCoupons(EcomSalesHeader, EcomSalesLine, CouponTypes);
        exit(true);
    end;

    local procedure CheckIfLineCanBeProcessed(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var CouponTypes: List of [Code[20]])
    var
        UnableToIdentifyCouponTypeErr: Label 'Unable to identify the coupon type for ecommerce sales document line %1.', Comment = '%1 - ecommerce sales document line record Id.', Locked = true;
    begin
        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            EcomSalesHeader.FieldError("Creation Status");

        if EcomSalesLine.Subtype <> EcomSalesLine.Subtype::Coupon then
            EcomSalesLine.FieldError(Subtype);

        if not EcomSalesLine.Captured then
            EcomSalesLine.FieldError(Captured);

        if EcomSalesLine."Document Type" = EcomSalesLine."Document Type"::"Return Order" then
            EcomSalesLine.FieldError("Document Type");

        if EcomSalesLine."Virtual Item Process Status" = EcomSalesLine."Virtual Item Process Status"::Processed then
            EcomSalesLine.FieldError(EcomSalesLine."Virtual Item Process Status");

        if not IsCouponItem(EcomSalesLine, true, CouponTypes, true) then
            Error(UnableToIdentifyCouponTypeErr, EcomSalesLine.RecordId());
    end;

    local procedure IssueCoupons(EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line"; var CouponTypes: List of [Code[20]])
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesCouponLine: Record "NPR Ecom Sales Coupon Link";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        EcomCreateWalletMgt: Codeunit "NPR EcomCreateWalletMgt";
        CouponTypeCode: Code[20];
        i: Integer;
        QtyTotalInt: Integer;
        ProcessCouponType: Boolean;
    begin
        QtyTotalInt := Round(EcomSalesLine.Quantity, 1, '>');
        if QtyTotalInt <= 0 then
            QtyTotalInt := 1;

        foreach CouponTypeCode in CouponTypes do begin
            CouponType.Get(CouponTypeCode);
            CouponType.TestField("Reference No. Pattern");
            if IsCouponIssueModuleOnAttractionWallet(CouponType) then
                ProcessCouponType := EcomCreateWalletMgt.IsPartOfAttractionWalletBundle(EcomSalesLine)
            else
                ProcessCouponType := true;
            if ProcessCouponType then
                for i := 1 to QtyTotalInt do begin
                    Clear(Coupon);
                    Coupon.Init();
                    Coupon.Validate("Coupon Type", CouponType.Code);
                    Coupon."No." := '';
                    Coupon.Insert(true);

                    CouponMgt.PostIssueCoupon(Coupon, EcomSalesHeader."External No.");

                    EcomSalesCouponLine.Init();
                    EcomSalesCouponLine."Source" := EcomSalesCouponLine."Source"::"Ecom Sales Document";
                    EcomSalesCouponLine."Source System Id" := EcomSalesHeader.SystemId;
                    EcomSalesCouponLine."Source Line System Id" := EcomSalesLine.SystemId;
                    EcomSalesCouponLine."Coupon System Id" := Coupon.SystemId;
                    EcomSalesCouponLine."Entry No." := 0;
                    EcomSalesCouponLine.Insert(true);
                end;
        end;
    end;

    internal procedure ShowRelatedCouponsAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesCouponLine: Record "NPR Ecom Sales Coupon Link";
    begin
        EcomSalesCouponLine.SetRange("Source", EcomSalesCouponLine."Source"::"Ecom Sales Document");
        EcomSalesCouponLine.SetRange("Source System Id", EcomSalesHeader.SystemId);
        ShowRelatedCouponsAction(EcomSalesCouponLine);
    end;

    internal procedure ShowRelatedCouponsAction(EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomSalesCouponLine: Record "NPR Ecom Sales Coupon Link";
    begin
        EcomSalesCouponLine.SetRange("Source", EcomSalesCouponLine."Source"::"Ecom Sales Document");
        EcomSalesCouponLine.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        ShowRelatedCouponsAction(EcomSalesCouponLine);
    end;

    local procedure ShowRelatedCouponsAction(var EcomSalesCouponLine: Record "NPR Ecom Sales Coupon Link")
    var
        Coupon: Record "NPR NpDc Coupon";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
    begin
        if not EcomSalesCouponLine.FindSet() then
            exit;

        repeat
            if Coupon.GetBySystemId(EcomSalesCouponLine."Coupon System Id") then begin
                TempCoupon := Coupon;
                if TempCoupon.Insert() then;
            end;
        until EcomSalesCouponLine.Next() = 0;

        if TempCoupon.IsEmpty() then
            exit;
        Page.RunModal(0, TempCoupon);
    end;

    internal procedure IsCouponItem(EcomSalesLine: Record "NPR Ecom Sales Line"; CheckCouponTypes: Boolean): Boolean
    var
        DummyCouponTypeList: List of [Code[20]];
    begin
        exit(IsCouponItem(EcomSalesLine, false, DummyCouponTypeList, CheckCouponTypes));
    end;

    internal procedure IsCouponItem(EcomSalesLine: Record "NPR Ecom Sales Line"; GetCouponTypes: Boolean; var CouponTypes: List of [Code[20]]; CheckCouponTypes: Boolean): Boolean
    var
        EcomSalesCouponSetupLine: Record "NPR NpDc Iss.OnEcomSale S.Line";
        WalletCouponSetup: Record "NPR WalletCouponSetup";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        Clear(CouponTypes);
        if not (EcomSalesDocUtils.GetItemNoAndVariantNoFromEcomSalesLine(EcomSalesLine, ItemNo, VariantCode) and (ItemNo <> '')) then
            exit(false);
        if not GetCouponTypes then
            GetCouponTypes := CheckCouponTypes;

        WalletCouponSetup.SetCurrentKey(TriggerOnItemNo);
        WalletCouponSetup.SetRange(TriggerOnItemNo, ItemNo);
        WalletCouponSetup.SetFilter("Coupon Type", '<>%1', '');
        if WalletCouponSetup.FindSet() then
            repeat
                if GetCouponTypes then begin
                    if not CouponTypes.Contains(WalletCouponSetup."Coupon Type") then
                        if CouponTypeIsEnabled(WalletCouponSetup."Coupon Type") then
                            CouponTypes.Add(WalletCouponSetup."Coupon Type");
                end else
                    if CouponTypeIsEnabled(WalletCouponSetup."Coupon Type") then
                        exit(true);
            until WalletCouponSetup.Next() = 0;

        EcomSalesCouponSetupLine.SetCurrentKey(Type, "No.", "Variant Code");
        EcomSalesCouponSetupLine.SetRange(Type, EcomSalesCouponSetupLine.Type::Item);
        EcomSalesCouponSetupLine.SetRange("No.", ItemNo);
        if VariantCode <> '' then
            EcomSalesCouponSetupLine.SetFilter("Variant Code", '%1|%2', '', VariantCode)
        else
            EcomSalesCouponSetupLine.SetRange("Variant Code", VariantCode);
        EcomSalesCouponSetupLine.SetFilter("Coupon Type", '<>%1', '');
        if EcomSalesCouponSetupLine.FindSet() then
            repeat
                if GetCouponTypes then begin
                    if not CouponTypes.Contains(EcomSalesCouponSetupLine."Coupon Type") then
                        if CouponTypeIsEnabled(EcomSalesCouponSetupLine."Coupon Type") then
                            CouponTypes.Add(EcomSalesCouponSetupLine."Coupon Type");
                end else
                    if CouponTypeIsEnabled(EcomSalesCouponSetupLine."Coupon Type") then
                        exit(true);
            until EcomSalesCouponSetupLine.Next() = 0;

        if CouponTypes.Count() = 0 then
            exit(false);
        if CheckCouponTypes then
            CheckCouponTypesEligible(EcomSalesLine, CouponTypes);
        exit(true);
    end;

    local procedure CouponTypeIsEnabled(CouponTypeCode: Code[20]): Boolean
    var
        CouponType: Record "NPR NpDc Coupon Type";
    begin
        if not CouponType.Get(CouponTypeCode) then
            exit(false);
        exit(CouponType.Enabled);
    end;

    local procedure CheckCouponTypesEligible(EcomSalesLine: Record "NPR Ecom Sales Line"; var CouponTypes: List of [Code[20]])
    var
        CouponType: Record "NPR NpDc Coupon Type";
        CouponTypeCode: Code[20];
        SupportedModuleList: List of [Code[20]];
        UnsupportedModuleErr: Label 'Coupon type %1 has Issue Coupon Module %2 which is not supported for ecommerce sales documents. Supported modules: %3. Ecommerce sales document line: %4', Comment = '%1 - coupon type, %2 - module code, %3 - supported module codes, %4 - ecommerce sales document line record Id.', Locked = true;
    begin
        SupportedModuleList := SupportedModules();
        foreach CouponTypeCode in CouponTypes do begin
            CouponType.Get(CouponTypeCode);
            if not SupportedModuleList.Contains(CouponType."Issue Coupon Module") then
                Error(UnsupportedModuleErr, CouponTypeCode, CouponType."Issue Coupon Module", SupportedModuleListStr(SupportedModuleList), EcomSalesLine.RecordId());
        end;
    end;

    local procedure SupportedModules(): List of [Code[20]]
    var
        AttractionWalletCoupon: Codeunit "NPR AttractionWalletCoupon";
        OnEcomSaleCouponModule: Codeunit "NPR OnEcomSaleCouponModule";
        ModuleList: List of [Code[20]];
    begin
        ModuleList.Add(AttractionWalletCoupon.ModuleCode());
        ModuleList.Add(OnEcomSaleCouponModule.ModuleCode());
        exit(ModuleList);
    end;

    local procedure SupportedModuleListStr(var ModuleList: List of [Code[20]]): Text
    var
        ModuleCode: Code[20];
        Result: Text;
    begin
        foreach ModuleCode in ModuleList do begin
            if Result <> '' then
                Result += ', ';
            Result += ModuleCode;
        end;
        exit(Result);
    end;

    internal procedure EnsureNoAttractionCouponsOutsideWallets(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        AttractionWalletCoupon: Codeunit "NPR AttractionWalletCoupon";
        EcomCreateWalletMgt: Codeunit "NPR EcomCreateWalletMgt";
        AttrCouponOutsideWalletErr: Label 'Ecommerce sales document line %1 represents a coupon line with coupon type that has "Issue Coupon Module" set to "%2", but this line is not part of an attraction wallet bundle. Please ensure that all such coupon lines are part of an attraction wallet bundle before submitting the ecommerce sales document.', Comment = '%1 - ecommerce sales document line record Id, %2 - issue coupon module On-Attraction-Wallet', Locked = true;
    begin
        EcomSalesLine.SetCurrentKey("Document Entry No.", Subtype);
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Coupon);
        if EcomSalesLine.FindSet() then
            repeat
                if HasCouponIssueModuleOnAttractionWallet(EcomSalesLine) then
                    if not EcomCreateWalletMgt.IsPartOfAttractionWalletBundle(EcomSalesLine) then
                        Error(AttrCouponOutsideWalletErr, EcomSalesLine.RecordId(), AttractionWalletCoupon.ModuleCode());
            until EcomSalesLine.Next() = 0;
    end;

    local procedure HasCouponIssueModuleOnAttractionWallet(EcomSalesLine: Record "NPR Ecom Sales Line"): Boolean
    var
        CouponTypes: List of [Code[20]];
        CouponTypeCode: Code[20];
    begin
        if IsCouponItem(EcomSalesLine, true, CouponTypes, false) then
            foreach CouponTypeCode in CouponTypes do
                if IsCouponIssueModuleOnAttractionWallet(CouponTypeCode) then
                    exit(true);
        exit(false);
    end;

    local procedure IsCouponIssueModuleOnAttractionWallet(CouponTypeCode: Code[20]): Boolean
    var
        CouponType: Record "NPR NpDc Coupon Type";
    begin
        if not CouponType.Get(CouponTypeCode) then
            exit(false);
        exit(IsCouponIssueModuleOnAttractionWallet(CouponType));
    end;

    local procedure IsCouponIssueModuleOnAttractionWallet(CouponType: Record "NPR NpDc Coupon Type"): Boolean
    var
        AttractionWalletCoupon: Codeunit "NPR AttractionWalletCoupon";
    begin
        exit(CouponType."Issue Coupon Module" = AttractionWalletCoupon.ModuleCode());
    end;
}
#endif
