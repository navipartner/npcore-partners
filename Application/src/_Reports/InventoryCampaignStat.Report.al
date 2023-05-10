report 6014499 "NPR Inventory Campaign Stat."
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Inventory Campaign Stat..rdlc';
    Caption = 'Inventory Discount Statistic';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Period Discount"; "NPR Period Discount")
        {
            RequestFilterFields = "Code";
            column(PeriodDiscountLineVendorNo; PeriodDiscountLineVendorNo)
            {
            }
            column(AppliedFilters; AppliedFilters)
            {
            }
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(CompanyInfoPicture; CompanyInfo.Picture)
            {
            }
            column("Code"; Code)
            {
            }
            column(Description; Description)
            {
            }
            column(StartingDate; "Starting Date")
            {
            }
            column(EndingDate; "Ending Date")
            {
            }
            dataitem("Period Discount Line"; "NPR Period Discount Line")
            {
                CalcFields = "Quantity Sold", Turnover;
                DataItemLink = Code = FIELD(Code);
                RequestFilterFields = "Vendor No.", "Location Filter";
                column(Code_PeriodDiscountLine; Code)
                {
                }
                column(PeriodLineItemNo; "Item No.")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineDesc; Description)
                {
                    AutoFormatType = 1;
                }
                column(ItemUnitPrice; Item."Unit Cost")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineUnitPrice; _UnitPrice)
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineCampaignUnitPrice; "Campaign Unit Price")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineQuantitySold; _QuantitySold)
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineTurnover; _Turnover)
                {
                    AutoFormatType = 1;
                }
                column(Bought; purchase)
                {
                    AutoFormatType = 1;
                }
                column(BoughtFor; boughtFor)
                {
                    AutoFormatType = 1;
                }
                column(AmountLeftover; restk)
                {
                    AutoFormatType = 1;
                }
                column(TeoreticalAv; teodg)
                {
                    AutoFormatType = 1;
                }
                column(ConsumeOld; Item.Inventory)
                {
                    AutoFormatType = 1;
                }
                column(ItemNetChange; Item."Net Change")
                {
                    AutoFormatType = 1;
                }
                column(db; db)
                {
                    AutoFormatType = 1;
                }
                column(dg; dg)
                {
                    AutoFormatType = 1;
                }
                column(PeriodDiscountLine_VendorNo; "Vendor No.")
                {
                }
                column(Caption_PeriodDiscountLine_VendorNo; Vendor.FieldCaption("No."))
                {
                }
                column(Vendor_Name; Vendor.Name)
                {
                }
                column(Variant_Code; "Variant Code")
                {
                }

                trigger OnPreDataItem()
                var
                    "Date": Record "Date";
                begin
                    if PeriodDateFilter <> '' then begin
                        "Date".SetRange("Period Type", "Date"."Period Type"::"Date");
                        "Date".SetFilter("Date"."Period Start", PeriodDateFilter);

                        "Period Discount".SetFilter("Starting Date", '<=%1', "Date".GetRangeMax("Date"."Period Start"));
                        "Period Discount".SetFilter("Ending Date", '>=%1', "Date".GetRangeMin("Date"."Period Start"));
                    end;
                    CompanyInfo.CalcFields(Picture);

                    PeriodDiscountLineVendorNo := "Period Discount Line".GetFilter("Vendor No.");

                    if "Period Discount".GetFilters <> '' then
                        AppliedFilters := "Period Discount".GetFilters;

                    if "Period Discount Line".GetFilters <> '' then begin
                        if AppliedFilters <> '' then
                            AppliedFilters := StrSubstNo('%1; %2', AppliedFilters, "Period Discount Line".GetFilters)
                        else
                            AppliedFilters := "Period Discount Line".GetFilters;
                    end;

                end;

                trigger OnAfterGetRecord()
                begin
                    Clear(_UnitPrice);
                    Clear(_QuantitySold);
                    Clear(_Turnover);
                    _UnitPrice := "Unit Price";
                    if "Distribution Item" then
                        F := 'F'
                    else
                        F := '';

                    Clear(Vendor);
                    if "Period Discount Line"."Vendor No." <> '' then
                        Vendor.Get("Period Discount Line"."Vendor No.");

                    Item.SetRange("No.", "Item No.");
                    Item.SetRange("Date Filter", 0D, "Period Discount"."Ending Date");
                    Item.SetFilter("Location Filter", "Period Discount Line".GetFilter("Location Filter"));
                    Item.SetRange("Variant Filter", "Variant Code");
                    if Item.FindFirst() then;
                    Item.CalcFields("Net Change", Inventory);

                    if VATPostingsetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then begin
                        momsregulering := (1 + (VATPostingsetup."VAT %" / 100)); //* "VAT %" / 100);
                    end else
                        momsregulering := 1;

                    _UnitPrice := _UnitPrice / momsregulering;
                    "Campaign Unit Price" := "Campaign Unit Price" / momsregulering;

                    if ("Campaign Unit Price" <> 0) then
                        teodg := Round(("Campaign Unit Price" - "Campaign Unit Cost") / "Campaign Unit Price" * 100, 0.1)
                    else
                        teodg := 0;

                    Item.SetRange("Date Filter", "Period Discount"."Starting Date", "Period Discount"."Ending Date");
                    Item.SetFilter("Location Filter", "Period Discount Line".GetFilter("Location Filter"));
                    if Item.Find('-') then;
                    Item.CalcFields("COGS (LCY)", "Sales (LCY)", "Sales (Qty.)", Inventory);
                    _QuantitySold := Item."Sales (Qty.)";
                    if ("Quantity Sold" = 0) and kunvarermedsalg then
                        CurrReport.Skip();

                    _Turnover := Item."Sales (LCY)";
                    if Item."Sales (LCY)" <> 0 then begin
                        db := (Item."Sales (LCY)") - (Item."COGS (LCY)");
                        totdb := totdb + db;
                        dg := Round(db / (Item."Sales (LCY)") * 100, 0.1);
                    end else begin
                        db := 0;
                        dg := 0;
                    end;

                    restk := purchase - _QuantitySold;
                    if restk < 0 then restk := 0;

                    Item.SetRange("Date Filter", 0D, "Period Discount"."Ending Date");
                    Item.CalcFields("Net Change");
                end;

            }
        }

    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Setting)
                {
                    Caption = 'Setting';
                    field("Period_Date_Filter"; PeriodDateFilter)
                    {
                        Caption = 'Period Date Filter';
                        ToolTip = 'Specifies the value of the Period Date Filter';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        var
                            FilterTokens: Codeunit "Filter Tokens";
                        begin
                            FilterTokens.MakeDateFilter(PeriodDateFilter);
                        end;
                    }
                }
            }
        }
    }
    labels
    {
        Report_Lbl = 'Campaign Discount Statistics';
        Page_Lbl = 'Page';
        Of_Lbl = 'of';
        ItemNo_Lbl = 'No.';
        VendorNo_Lbl = 'Vendor No.';
        VendorName_Lbl = 'Vendor Name';
        ItemDescription_Lbl = 'Description';
        ItemUnitPrice_Lbl = 'Cost price';
        UnitPrice_Lbl = 'Sales price Excl. VAT';
        CampainUnitPrice_Lbl = 'Period price Excl. VAT';
        QuantitySold_Lbl = 'Sales Quantity';
        Turnover_Lbl = 'Sales Amount';
        Purch_Lbl = 'Pieces';
        Purchfor_Lbl = 'Amount';
        restk_Lbl = 'Leftover inv. from purchases';
        teodg_Lbl = 'Theoretical profit %';
        forbgllager_Caption = 'Inventory';
        NetChange_Lbl = 'Inventory per ending date';
        db_Lbl = 'Realized Profit Amount';
        dg_Lbl = 'Realized Profit %';
        PurchTilKampagnenLbl = 'Purchased for the campaign';
        RealiseretAvanceLbl = 'Realised Advance';
        CampaignTotalLbl = 'Campaign total';
        ChosenVendorLbl = 'Chosen vendor:';
        PeriodLbl = 'Period: ';
        PageNoinAd = 'Page No. in Advert';
        ShowFilters = 'Applied Filters:';
        VariantCodeLbL = 'Variant Code';
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        Item: Record Item;
        PeriodDateFilter: Text;
        VATPostingsetup: Record "VAT Posting Setup";
        _UnitPrice: Decimal;
        _QuantitySold: Decimal;
        _Turnover: Decimal;
        Vendor: Record Vendor;
        kunvarermedsalg: Boolean;
        boughtFor: Decimal;
        db: Decimal;
        dg: Decimal;
        momsregulering: Decimal;
        purchase: Decimal;
        restk: Decimal;
        teodg: Decimal;
        totdb: Decimal;
        F: Text[30];
        PeriodDiscountLineVendorNo: Text;
        AppliedFilters: Text;
}

