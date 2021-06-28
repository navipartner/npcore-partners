codeunit 6014614 "NPR Retail Campaign Calc. Mgt."
{
    // NPR5.38.01/MHA /20171221  CASE 299436 Object create - Retail Campaign


    trigger OnRun()
    begin
    end;

    procedure CalcCostAmount(CampaignCode: Code[20]; LineNo: Integer) CostAmount: Decimal
    var
        RetailCampaignItemTotals: Query "NPR Retail Campgn. Item Totals";
    begin
        if CampaignCode = '' then
            exit(0);

        RetailCampaignItemTotals.SetRange(Code, CampaignCode);
        if LineNo <> 0 then
            RetailCampaignItemTotals.SetRange(Line_No, LineNo);
        if RetailCampaignItemTotals.Open() then begin
            if RetailCampaignItemTotals.Read() then
                CostAmount := RetailCampaignItemTotals.Sum_Cost_Amount_Actual;

            RetailCampaignItemTotals.Close();
        end;

        exit(-CostAmount);
    end;

    procedure CalcProfit(CampaignCode: Code[20]; LineNo: Integer) Profit: Decimal
    var
        RetailCampaignItemTotals: Query "NPR Retail Campgn. Item Totals";
    begin
        if CampaignCode = '' then
            exit(0);

        RetailCampaignItemTotals.SetRange(Code, CampaignCode);
        if LineNo <> 0 then
            RetailCampaignItemTotals.SetRange(Line_No, LineNo);
        if RetailCampaignItemTotals.Open() then begin
            if RetailCampaignItemTotals.Read() then
                Profit := RetailCampaignItemTotals.Sum_Sales_Amount_Actual + RetailCampaignItemTotals.Sum_Cost_Amount_Actual;

            RetailCampaignItemTotals.Close();
        end;

        exit(Profit);
    end;

    procedure CalcProfitPct(CampaignCode: Code[20]; LineNo: Integer) ProfitPct: Decimal
    var
        RetailCampaignItemTotals: Query "NPR Retail Campgn. Item Totals";
        Profit: Decimal;
    begin
        if CampaignCode = '' then
            exit(0);

        RetailCampaignItemTotals.SetRange(Code, CampaignCode);
        if LineNo <> 0 then
            RetailCampaignItemTotals.SetRange(Line_No, LineNo);
        if RetailCampaignItemTotals.Open() then begin
            if RetailCampaignItemTotals.Read() and (RetailCampaignItemTotals.Sum_Sales_Amount_Actual <> 0) then begin
                Profit := RetailCampaignItemTotals.Sum_Sales_Amount_Actual + RetailCampaignItemTotals.Sum_Cost_Amount_Actual;
                ProfitPct := (Profit / RetailCampaignItemTotals.Sum_Sales_Amount_Actual) * 100;
            end;

            RetailCampaignItemTotals.Close();
        end;

        exit(ProfitPct);
    end;

    procedure CalcSalesAmount(CampaignCode: Code[20]; LineNo: Integer) SalesAmount: Decimal
    var
        RetailCampaignItemTotals: Query "NPR Retail Campgn. Item Totals";
    begin
        if CampaignCode = '' then
            exit(0);

        RetailCampaignItemTotals.SetRange(Code, CampaignCode);
        if LineNo <> 0 then
            RetailCampaignItemTotals.SetRange(Line_No, LineNo);
        if RetailCampaignItemTotals.Open() then begin
            if RetailCampaignItemTotals.Read() then
                SalesAmount := RetailCampaignItemTotals.Sum_Sales_Amount_Actual;

            RetailCampaignItemTotals.Close();
        end;

        exit(SalesAmount);
    end;

    procedure DrilldownItemEntries(CampaignCode: Code[20]; LineNo: Integer) Turnover: Decimal
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        RetailCampaignItemEntries: Query "NPR Retail Cmpgn. Item Entries";
    begin
        if CampaignCode = '' then
            exit;

        RetailCampaignItemEntries.SetRange(Code, CampaignCode);
        if LineNo <> 0 then
            RetailCampaignItemEntries.SetRange(Line_No, LineNo);
        if RetailCampaignItemEntries.Open() then begin
            while RetailCampaignItemEntries.Read() do begin
                ItemLedgEntry.Get(RetailCampaignItemEntries.Entry_No);
                TempItemLedgEntry.Init();
                TempItemLedgEntry := ItemLedgEntry;
                TempItemLedgEntry.Insert();
            end;

            RetailCampaignItemEntries.Close();
        end;

        PAGE.Run(0, TempItemLedgEntry);
    end;
}

