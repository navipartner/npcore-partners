report 6014499 "Inventory Campaign Stat."
{
    // NPK1.01/20130603/TR CASE : 176941 - Copied from nyeste.
    // NPR4.14/KN/20150818 CASE 220291 Added label, CampaignTotalLbl, to replace hardcoded text in textbox.
    // NPR4.14/KN/20150821 CASE 221165 Added two labels, ChosenVendorLbl and PeriodLbl, to replace hardcoded text in textboxes.
    // NPR5.25/JLK /20160726 CASE 247117 Corrected Net Change
    //                                   Hide not calculated variables from rdlc
    // NPR5.38/TS  /20180108  CASE 299279 Added Page No in advert.
    // NPR5.38/JKL /20180125  CASE 299279 Added Vendor No. Vendor Name
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.41/JKL /20180423 CASE 299279  removed calc fields on starting date / ending dat, Consumption Inventory changed to show current inventory + location filter active
    DefaultLayout = RDLC;
    RDLCLayout = './Inventory Campaign Stat..rdlc';

    Caption = 'Inventory Campaign Stat.';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Period Discount";"Period Discount")
        {
            RequestFilterFields = "Code";
            column(PeriodDiscountLineVendorNo;PeriodDiscountLineVendorNo)
            {
            }
            column(CompanyInfoName;CompanyInfo.Name)
            {
            }
            column(CompanyInfoPicture;CompanyInfo.Picture)
            {
            }
            column("Code";"Period Discount".Code)
            {
            }
            column(Description;"Period Discount".Description)
            {
            }
            column(StartingDate;"Period Discount"."Starting Date")
            {
            }
            column(EndingDate;"Period Discount"."Ending Date")
            {
            }
            dataitem("Period Discount Line";"Period Discount Line")
            {
                CalcFields = "Quantity Sold",Turnover;
                DataItemLink = Code=FIELD(Code);
                RequestFilterFields = "Vendor No.","Location Filter";
                column(Code_PeriodDiscountLine;"Period Discount Line".Code)
                {
                }
                column(PeriodLineItemNo;"Period Discount Line"."Item No.")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineDesc;"Period Discount Line".Description)
                {
                    AutoFormatType = 1;
                }
                column(ItemUnitPrice;vare."Unit Cost")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineUnitPrice;"Period Discount Line"."Unit Price")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineCampaignUnitPrice;"Period Discount Line"."Campaign Unit Price")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineQuantitySold;"Period Discount Line"."Quantity Sold")
                {
                    AutoFormatType = 1;
                }
                column(PeriodLineTurnover;"Period Discount Line".Turnover)
                {
                    AutoFormatType = 1;
                }
                column(Bought;purchase)
                {
                    AutoFormatType = 1;
                }
                column(BoughtFor;boughtFor)
                {
                    AutoFormatType = 1;
                }
                column(AmountLeftover;restk)
                {
                    AutoFormatType = 1;
                }
                column(TeoreticalAv;teodg)
                {
                    AutoFormatType = 1;
                }
                column(ConsumeOld;vare.Inventory)
                {
                    AutoFormatType = 1;
                }
                column(ItemNetChange;vare."Net Change")
                {
                    AutoFormatType = 1;
                }
                column(db;db)
                {
                    AutoFormatType = 1;
                }
                column(dg;dg)
                {
                    AutoFormatType = 1;
                }
                column(Pagenoinadvert_PeriodDiscountLine;"Period Discount Line"."Page no. in advert")
                {
                }
                column(PeriodDiscountLine_VendorNo;"Period Discount Line"."Vendor No.")
                {
                }
                column(Caption_PeriodDiscountLine_VendorNo;Vendor.FieldCaption("No."))
                {
                }
                column(Vendor_Name;Vendor.Name)
                {
                }
                column(Caption_Vendor_name;Vendor.FieldCaption(Name))
                {
                }

                trigger OnAfterGetRecord()
                begin
                    //-NPR5.41 [299279]
                    //"Period Discount Line".CALCFIELDS("Period Discount Line"."Starting Date");
                    //+NPR5.41 [299279]

                    if "Distribution Item" then
                      F:='F'
                    else
                      F:='';

                    //NPR5.38 [302123]
                    Clear(Vendor);
                    if "Period Discount Line"."Vendor No." <> '' then
                      Vendor.Get("Period Discount Line"."Vendor No.");
                    //NPR5.38 [302123]

                    vare.SetRange("No.", "Item No.");
                    vare.SetRange("Date Filter", 0D,"Period Discount"."Ending Date");
                    //-NPR5.41 [299279]
                    vare.SetFilter("Location Filter","Period Discount Line".GetFilter("Location Filter"));
                    //+NPR5.41 [299279]

                    if vare.Find('-') then;
                    //-NPR5.41 [299279]
                    //vare.CALCFIELDS("Net Change");
                    vare.CalcFields("Net Change",Inventory);
                    //+NPR5.41 [299279]

                     if VATPostingsetup.Get(vare."VAT Bus. Posting Gr. (Price)",vare."VAT Prod. Posting Group") then begin
                      momsregulering:=(1 + ( VATPostingsetup."VAT %" / 100)); //* "VAT %" / 100);
                       end else
                      momsregulering:=1;

                    if ("Campaign Unit Price"<>0) then
                      teodg:=Round((("Campaign Unit Price"/momsregulering)-"Campaign Unit Cost")/("Campaign Unit Price"/momsregulering) * 100,0.1)
                    else
                      teodg:=0;

                    //+NPR5.25
                    //vare.SETRANGE("No.", "Item No.");
                    //vare.SETRANGE("Date Filter", 0D,"Ending date");
                    //IF vare.FIND('-') THEN;
                    //vare.CALCFIELDS("Net Change");
                    //-NPR5.25

                    vare.SetRange("No.", "Item No.");
                    vare.SetFilter("Date Filter",'%1..%2',"Period Discount"."Starting Date","Period Discount"."Ending Date");
                    //-NPR5.41 [299279]
                    vare.SetFilter("Location Filter","Period Discount Line".GetFilter("Location Filter"));
                    //+NPR5.41 [299279]
                    if vare.Find('-') then;
                    //+NPR5.25
                    //vare.CALCFIELDS("COGS (LCY)","Sales (LCY)","Sales (Qty.)");
                    //vare.CALCFIELDS("COGS (LCY)","Sales (LCY)","Sales (Qty.)","Net Change");
                    //-NPR5.41 [299279]
                    //vare.CALCFIELDS("COGS (LCY)","Sales (LCY)","Sales (Qty.)","Net Change");
                    vare.CalcFields("COGS (LCY)","Sales (LCY)","Sales (Qty.)","Net Change",Inventory);
                    //+NPR5.41 [299279]
                    //-NPR5.25
                    "Quantity Sold":= vare."Sales (Qty.)";
                    if ("Quantity Sold"=0) and kunvarermedsalg then
                      CurrReport.Skip;

                    Turnover:=vare."Sales (LCY)";
                    if vare."Sales (LCY)" <> 0 then begin
                     db:=(vare."Sales (LCY)")-(vare."COGS (LCY)");
                     totdb:=totdb+db;
                     dg:=Round(db/(vare."Sales (LCY)")*100,0.1);
                    end else begin
                     db := 0;
                     dg := 0;
                    end;

                    restk:=purchase-"Quantity Sold";
                    if restk < 0 then forbgllager := restk * -1;
                    if restk >= 0 then forbgllager := 0;
                    if restk < 0 then restk := 0;
                end;

                trigger OnPreDataItem()
                begin
                    //-NPR5.39
                    //CurrReport.CREATETOTALS("Quantity Sold",Turnover);
                    //+NPR5.39
                end;
            }

            trigger OnPreDataItem()
            begin
                //-NPR5.39
                //CurrReport.CREATETOTALS("Period Discount Line".Turnover, "Period Discount Line"."Quantity Sold",purchase, boughtFor, restk, teodg, db);
                //+NPR5.39
                CompanyInfo.CalcFields(Picture);
                PeriodDiscountLineVendorNo := "Period Discount Line".GetFilter("Vendor No.");
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
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
        CompanyInfo.Get;
        //-NPR5.39
        // Object.SETRANGE(ID,6014499);
        // Object.SETRANGE(Type,3);
        // Object.FIND('-');
        //+NPR5.39
    end;

    var
        CompanyInfo: Record "Company Information";
        Vendor: Record Vendor;
        F: Text[30];
        kunvarermedsalg: Boolean;
        teodg: Decimal;
        db: Decimal;
        dg: Decimal;
        vare: Record Item;
        purchase: Decimal;
        boughtFor: Decimal;
        restk: Decimal;
        forbgllager: Decimal;
        totdb: Decimal;
        VATPostingsetup: Record "VAT Posting Setup";
        momsregulering: Decimal;
        PeriodDiscountLineVendorNo: Text[100];
}

