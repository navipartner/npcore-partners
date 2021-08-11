codeunit 6014595 "NPR New Prices Upgrade"
{

    Subtype = Upgrade;


    trigger OnUpgradePerCompany()
    begin
        RemoveDiscountPriorityRecords();
    end;

    procedure RemoveDiscountPriorityRecords()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Prices Upgrade', 'OnUpgradeDataPerCompany');

        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR New Prices Upgrade")) then
            exit;

        InitDiscountPriority();

        UpdateMagentoSetup();
        FillPriceListNos();
        EnableFeature('SalesPrices');

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR New Prices Upgrade"));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateMagentoSetup()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if MagentoSetup.Get() then begin
            MagentoSetup."Replicate to Price Source Type" := ConvertPriceType(MagentoSetup."Replicate to Sales Type");
            MagentoSetup.Modify();
        end
    end;

    local procedure ConvertPriceType(ReplicatetoSalesType: Enum "Sales Price Type") PriceSourceType: Enum "Price Source Type"
    begin
        case ReplicatetoSalesType of
            ReplicatetoSalesType::"All Customers":
                exit(PriceSourceType::"All Customers");
            ReplicatetoSalesType::Campaign:
                exit(PriceSourceType::Campaign);
            ReplicatetoSalesType::Customer:
                exit(PriceSourceType::Customer);
            ReplicatetoSalesType::"Customer Price Group":
                exit(PriceSourceType::"Customer Price Group");
            else
        end;
    end;


    local procedure InitDiscountPriority()
    var
        DiscountPriority: Record "NPR Discount Priority";
        POSSalesDiscCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
        DiscountPriority.DeleteAll();
        POSSalesDiscCalcMgt.InitDiscountPriority(DiscountPriority);
    end;

    local procedure EnableFeature(FeatureName: Text)
    var
        FeatureKey: Record "Feature Key";
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        FeatureKey.SetRange(ID, FeatureName);
        FeatureKey.SetRange(Enabled, FeatureKey.Enabled::None);
        if FeatureKey.FindFirst() then begin
            FeatureKey.Validate(Enabled, FeatureKey.Enabled::"All Users");
            FeatureKey.Modify(true);

            if FeatureDataUpdateStatus.Get(FeatureKey.ID, CompanyName()) then
                Codeunit.Run(Codeunit::"Update Feature Data", FeatureDataUpdateStatus);
        end;
    end;

    local procedure FillPriceListNos()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        JobsSetup: Record "Jobs Setup";
        XJPLTok: Label 'J-PL', Locked = true;
        XJobPriceListLbl: Label 'Job Price List', Locked = true;
        XJ00001Tok: Label 'J00001', Locked = true;
        XJ99999Tok: Label 'J99999', Locked = true;
        XPPLTok: Label 'P-PL', Locked = true;
        XPurchasePriceListLbl: Label 'Purchase Price List', Locked = true;
        XP00001Tok: Label 'P00001', Locked = true;
        XP99999Tok: Label 'P99999', Locked = true;
        XSPLTok: Label 'S-PL', Locked = true;
        XSalesPriceListLbl: Label 'Sales Price List', Locked = true;
        XS00001Tok: Label 'S00001', Locked = true;
        XS99999Tok: Label 'S99999', Locked = true;
    begin
        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."Price List Nos." = '' then begin
            SalesReceivablesSetup."Price List Nos." := GetPriceListNoSeries(XSPLTok, XSalesPriceListLbl, XS00001Tok, XS99999Tok);
            SalesReceivablesSetup.Modify();
        end;
        PurchasesPayablesSetup.Get();
        if PurchasesPayablesSetup."Price List Nos." = '' then begin
            PurchasesPayablesSetup."Price List Nos." := GetPriceListNoSeries(XPPLTok, XPurchasePriceListLbl, XP00001Tok, XP99999Tok);
            PurchasesPayablesSetup.Modify();
        end;
        JobsSetup.Get();
        if JobsSetup."Price List Nos." = '' then begin
            JobsSetup."Price List Nos." := GetPriceListNoSeries(XJPLTok, XJobPriceListLbl, XJ00001Tok, XJ99999Tok);
            JobsSetup.Modify();
        end;
    end;

    procedure GetPriceListNoSeries(SeriesCode: Code[20]; Description: Text[100]; StartingNo: Code[20]; EndingNo: Code[20]): Code[20];
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(SeriesCode) then
            exit(SeriesCode);

        NoSeries.Init();
        NoSeries.Code := SeriesCode;
        NoSeries.Description := Description;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries.Insert();

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Ending No.", EndingNo);
        NoSeriesLine.Validate("Increment-by No.", 1);
        NoSeriesLine.Insert(true);
        exit(SeriesCode);
    end;
}

