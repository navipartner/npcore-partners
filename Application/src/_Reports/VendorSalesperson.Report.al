﻿report 6014529 "NPR Vendor/Salesperson"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/VendorSalesperson.rdlc';
    Caption = 'Vendor/Salesperson';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(PageNoCaptionLbl; PageNoCaptionLbl)
            {
            }
            column(Report_Caption; Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Salespersonfilter; Salespersonfilter)
            {
            }
            column(VendorFilter; VendorFilter)
            {
            }
            column(No_Vendor; Vendor."No.")
            {
            }
            column(Vendor_Caption; Vendor_Caption_Lbl)
            {
            }
            column(Name_Vendor; Vendor.Name)
            {
            }
            column(No_Caption; No_Caption_Lbl)
            {
            }
            column(Salesperson_Caption; Salesperson_Caption_Lbl)
            {
            }
            column(Turnover_Caption; Turnover_Caption_Lbl)
            {
            }
            column(Cost_Caption; Cost_Caption_Lbl)
            {
            }
            column(DbCaption; DbCaption_Lbl)
            {
            }
            column(CRPct_Caption; CRPct_Caption_Lbl)
            {
            }
            dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
            {
                PrintOnlyIfDetail = false;
                RequestFilterFields = "Code", "Date Filter";

                trigger OnAfterGetRecord()
                var
                    SalesLCY: Decimal;
                    COGSLCY: Decimal;
                begin
                    currentRec += 1;

                    d.Update(2, Round(((currentRec * 10000) / totalRec), 1));

                    TotalSale := 0;
                    TotalCOGS := 0;

                    Item.SetCurrentKey("Vendor No.");
                    Item.SetRange("Vendor No.", Vendor."No.");

                    if Item.Find('-') then
                        repeat
                            SetFilter("NPR Item Filter", Item."No.");
                            NPRGetVESalesLCY(SalesLCY);
                            NPRGetVECOGSLCY(COGSLCY);
                            TotalSale += SalesLCY;
                            TotalCOGS += COGSLCY;

                        until Item.Next() = 0 else
                        CurrReport.Skip();

                    if TotalSale <> 0 then begin
                        TempVaregruppe.Init();
                        TempVaregruppe."Item No." := "Salesperson/Purchaser".Code;
                        TempVaregruppe.Amount := TotalSale;
                        TempVaregruppe."Amount 2" := TotalCOGS;
                        if TempVaregruppe.Insert() then;

                    end else
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    TempVaregruppe.DeleteAll();

                    currentRec := 1;
                    totalRec := (Count() * 2);
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(Item_No_Varegruppetemp; TempVaregruppe."Item No.")
                {
                }
                column(Name_SalesPerson; SalesPerson.Name)
                {
                }
                column(Amount_Varegruppetemp; TempVaregruppe.Amount)
                {
                }
                column(Amount2_Varegruppetemp; TempVaregruppe."Amount 2")
                {
                }
                column(db; db)
                {
                }
                column(dg; dg)
                {
                }
                column(Total_Caption; Total_Caption_Lbl)
                {
                }
                column(turnovertotal; totalTurnover)
                {
                }
                column(forbrugtotal; forbrugtotal)
                {
                }
                column(dbtotal; dbtotal)
                {
                }
                column(dgtotal; dgtotal)
                {
                }
                column(turnoveralt; totalTotalTurnover)
                {
                }
                column(forbrugalt; forbrugalt)
                {
                }
                column(dbalt; dbalt)
                {
                }
                column(dgalt; dgalt)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    dg := 0;
                    db := 0;

                    if Number = 1 then begin
                        if not TempVaregruppe.Find('-') then
                            CurrReport.Break();
                    end else
                        if TempVaregruppe.Next() = 0 then
                            CurrReport.Break();

                    if (TempVaregruppe.Amount <> 0) then begin
                        dg := ((TempVaregruppe.Amount - TempVaregruppe."Amount 2") / TempVaregruppe.Amount) * 100;
                        db := TempVaregruppe.Amount - TempVaregruppe."Amount 2";
                    end;

                    if SalesPerson.Get(TempVaregruppe."Item No.") then;

                    totalTurnover += TempVaregruppe.Amount;
                    forbrugtotal += TempVaregruppe."Amount 2";
                    dbtotal += db;
                end;

                trigger OnPreDataItem()
                begin
                    TempVaregruppe.Ascending(false);

                    totalTurnover := 0;
                    forbrugtotal := 0;
                    dbtotal := 0;
                    dgtotal := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                d.Update(1, Name);
            end;

            trigger OnPostDataItem()
            begin
                d.Close();
                Clear(d);
            end;

            trigger OnPreDataItem()
            begin

                d.Open(Text001 + Text002, navn, taeller);
                d.Update(1, '');
                d.Update(2, 1);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }

    trigger OnInitReport()
    begin
        firmaoplysninger.Get();
        firmaoplysninger.CalcFields(Picture);

    end;

    trigger OnPreReport()
    begin
        Salespersonfilter := "Salesperson/Purchaser".GetFilters;
        VendorFilter := Vendor.GetFilters;
    end;

    var
        firmaoplysninger: Record "Company Information";
        Item: Record Item;
        TempVaregruppe: Record "Item Amount" temporary;
        SalesPerson: Record "Salesperson/Purchaser";
        db: Decimal;
        dbalt: Decimal;
        dbtotal: Decimal;
        dg: Decimal;
        dgalt: Decimal;
        dgtotal: Decimal;
        forbrugalt: Decimal;
        forbrugtotal: Decimal;
        TotalCOGS: Decimal;
        TotalSale: Decimal;
        totalTotalTurnover: Decimal;
        totalTurnover: Decimal;
        d: Dialog;
        currentRec: Integer;
        taeller: Integer;
        totalRec: Integer;
        Text002: Label '@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        Cost_Caption_Lbl: Label 'Cost';
        CRPct_Caption_Lbl: Label 'CR%';
        Text001: Label 'Creditor: #1################### \';
        DbCaption_Lbl: Label 'DB';
        No_Caption_Lbl: Label 'No.';
        PageNoCaptionLbl: Label 'Page';
        Salesperson_Caption_Lbl: Label 'Salesperson';
        Total_Caption_Lbl: Label 'Total';
        Turnover_Caption_Lbl: Label 'Turnover';
        Vendor_Caption_Lbl: Label 'Vendor';
        Report_Caption_Lbl: Label 'Vendor/Salesperson';
        navn: Text[30];
        VendorFilter: Text;
        Salespersonfilter: Text;
}

