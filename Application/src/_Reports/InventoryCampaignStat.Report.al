report 6014499 "NPR Inventory Campaign Stat."
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Inventory Campaign Stat..rdlc';
    Caption = 'Inventory Campaign Stat.';
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
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(CompanyInfoPicture; CompanyInfo.Picture)
            {
            }
            column("Code"; "Period Discount".Code)
            {
            }
            column(Description; "Period Discount".Description)
            {
            }
            column(StartingDate; "Period Discount"."Starting Date")
            {
            }
            column(EndingDate; "Period Discount"."Ending Date")
            {
            }
            dataitem("Period Discount Line"; "NPR Period Discount Line")
            {
                CalcFields = "Quantity Sold", Turnover;
                DataItemLink = Code = FIELD(Code);
                RequestFilterFields = "Vendor No.", "Location Filter";
                column(Code_PeriodDiscountLine; "Period Discount Line".Code)
                {
                }
                column(PeriodLineItemNo; "Period Discount Line"."Item No.")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineDesc; "Period Discount Line".Description)
                {
                    AutoFormatType = 1;
                }
                column(ItemUnitPrice; vare."Unit Cost")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineUnitPrice; "Period Discount Line"."Unit Price")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineCampaignUnitPrice; "Period Discount Line"."Campaign Unit Price")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineQuantitySold; "Period Discount Line"."Quantity Sold")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineTurnover; "Period Discount Line".Turnover)
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
                column(ConsumeOld; vare.Inventory)
                {
                    AutoFormatType = 1;
                }
                column(ItemNetChange; vare."Net Change")
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
                column(PeriodDiscountLine_VendorNo; "Period Discount Line"."Vendor No.")
                {
                }
                column(Caption_PeriodDiscountLine_VendorNo; Vendor.FieldCaption("No."))
                {
                }
                column(Vendor_Name; Vendor.Name)
                {
                }
                column(Caption_Vendor_name; Vendor.FieldCaption(Name))
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if "Distribution Item" then
                        F := 'F'
                    else
                        F := '';

                    Clear(Vendor);
                    if "Period Discount Line"."Vendor No." <> '' then
                        Vendor.Get("Period Discount Line"."Vendor No.");

                    vare.SetRange("No.", "Item No.");
                    vare.SetRange("Date Filter", 0D, "Period Discount"."Ending Date");
                    vare.SetFilter("Location Filter", "Period Discount Line".GetFilter("Location Filter"));
                    if vare.Find('-') then;
                    vare.CalcFields("Net Change", Inventory);

                    if VATPostingsetup.Get(vare."VAT Bus. Posting Gr. (Price)", vare."VAT Prod. Posting Group") then begin
                        momsregulering := (1 + (VATPostingsetup."VAT %" / 100)); //* "VAT %" / 100);
                    end else
                        momsregulering := 1;

                    if ("Campaign Unit Price" <> 0) then
                        teodg := Round((("Campaign Unit Price" / momsregulering) - "Campaign Unit Cost") / ("Campaign Unit Price" / momsregulering) * 100, 0.1)
                    else
                        teodg := 0;
                    vare.SetRange("No.", "Item No.");
                    vare.SetFilter("Date Filter", '%1..%2', "Period Discount"."Starting Date", "Period Discount"."Ending Date");
                    vare.SetFilter("Location Filter", "Period Discount Line".GetFilter("Location Filter"));
                    if vare.Find('-') then;
                    vare.CalcFields("COGS (LCY)", "Sales (LCY)", "Sales (Qty.)", "Net Change", Inventory);
                    "Quantity Sold" := vare."Sales (Qty.)";
                    if ("Quantity Sold" = 0) and kunvarermedsalg then
                        CurrReport.Skip();

                    Turnover := vare."Sales (LCY)";
                    if vare."Sales (LCY)" <> 0 then begin
                        db := (vare."Sales (LCY)") - (vare."COGS (LCY)");
                        totdb := totdb + db;
                        dg := Round(db / (vare."Sales (LCY)") * 100, 0.1);
                    end else begin
                        db := 0;
                        dg := 0;
                    end;

                    restk := purchase - "Quantity Sold";
                    if restk < 0 then restk := 0;
                end;

            }

            trigger OnPreDataItem()
            begin
                CompanyInfo.CalcFields(Picture);
                PeriodDiscountLineVendorNo := "Period Discount Line".GetFilter("Vendor No.");
            end;
        }
    }

    labels
    {
        Report_Lbl = 'Campaign sales statistics';
        Page_Lbl = 'Page';
        ItemNo_Lbl = 'No.';
        ItemDescription_Lbl = 'Description';
        ItemUnitPrice_Lbl = 'Current cost price';
        UnitPrice_Lbl = 'Indicative sales price incl. tax';
        CampainUnitPrice_Lbl = 'Period price incl. tax';
        QuantitySold_Lbl = 'Sales in pieces';
        Turnover_Lbl = 'Sale in Kr.';
        Purch_Lbl = 'Pieces';
        Purchfor_Lbl = 'Amount';
        restk_Lbl = 'Leftover inv. from purchases';
        teodg_Lbl = 'Theoretical profit %';
        forbgllager_Caption = 'Inventory';
        NetChange_Lbl = 'Inventory per ending date';
        db_Lbl = 'Realised Amount';
        dg_Lbl = 'Advance %';
        PurchTilKampagnenLbl = 'Purchased for the campaign';
        RealiseretAvanceLbl = 'Realised Advance';
        CampaignTotalLbl = 'Campaign total';
        ChosenVendorLbl = 'Chosen vendor';
        PeriodLbl = 'Period: ';
        PageNoinAd = 'Page No. in Advert';
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        vare: Record Item;
        VATPostingsetup: Record "VAT Posting Setup";
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
}

