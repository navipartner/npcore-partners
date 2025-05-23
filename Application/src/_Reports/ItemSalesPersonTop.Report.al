﻿report 6014474 "NPR Item/Sales Person Top"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/ItemSales Person Top.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Item/Salesperson Top';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Date Filter";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(SortHeading_Item; SortByTxtConst + ' ' + Format(SortBy) + ' ' + Format(SortingStigende))
            {
            }
            column(SalesQty_Item; Item."Sales (Qty.)")
            {
            }
            column(SalesLCY_Item; Item."Sales (LCY)")
            {
            }
            column(No_Item; Item."No.")
            {
            }
            column(Description_Item; Item.Description)
            {
            }
            column(Sorting_Item; SortOrder)
            {
            }
            column(SortBy_Item; SortBy)
            {
            }
            dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
            {
                DataItemLink = "NPR Item Filter" = FIELD("No.");
                DataItemTableView = SORTING(Code);
                PrintOnlyIfDetail = false;
                RequestFilterFields = "Code";
                column(Code_SalespersonPurchaser; "Salesperson/Purchaser".Code)
                {
                }
                column(Name_SalespersonPurchaser; "Salesperson/Purchaser".Name)
                {
                }
                column(SalesLCY_SalespersonPurchaser; SalesLCY)
                {
                }
                column(SalesQty_SalespersonPurchaser; SalesQty)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    NPRGetVESalesAndQty(SalesLCY, SalesQty);
                    if SalesLCY = 0 then
                        CurrReport.Skip();

                    if SortOrder then begin
                        TempItemAmount."Item No." := Code;

                        case SortBy of
                            SortBy::Turnover:
                                begin
                                    TempItemAmount.Amount := Abs(SalesLCY);
                                    TempItemAmount."Amount 2" := Abs(SalesQty);
                                end;
                            SortBy::"Qty.":
                                begin
                                    TempItemAmount.Amount := Abs(SalesQty);
                                    TempItemAmount."Amount 2" := Abs(SalesLCY);
                                end;
                        end;
                        TempItemAmount.Insert();
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    if SortOrder then
                        TempItemAmount.DeleteAll();

                    if Item.GetFilter("Date Filter") <> '' then
                        Item.CopyFilter("Date Filter", "Salesperson/Purchaser"."Date Filter");
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                MaxIteration = 0;
                column(Number_Integer; Integer.Number)
                {
                }
                column(SalespersonName_Integer; Salesperson.Name)
                {
                }
                column(Qty2_Integer; Qty2)
                {
                }
                column(CalcAmt_Integer; CalcAmt)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then begin
                        if not TempItemAmount.FindFirst() then
                            CurrReport.Break();
                    end else
                        if TempItemAmount.Next() = 0 then
                            CurrReport.Break();

                    if Salesperson.Get(TempItemAmount."Item No.") then;

                    Clear(CalcAmt);
                    Clear(Qty2);

                    case SortBy of
                        SortBy::Turnover:
                            begin
                                CalcAmt := TempItemAmount.Amount;
                                Qty2 := TempItemAmount."Amount 2";
                            end;
                        SortBy::"Qty.":
                            begin
                                Qty2 := TempItemAmount.Amount;
                                CalcAmt := TempItemAmount."Amount 2";
                            end;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    if not SortOrder then
                        CurrReport.Break();
                    SetRange(Number, 1, ShowQty);
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
                group("Option")
                {
                    field("Sorting"; SortOrder)
                    {
                        Caption = 'Sorting';

                        ToolTip = 'Specifies the value of the Sorting field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            ShowSort := false;
                            ShowSort := SortOrder;
                        end;
                    }
                    field("Sort By"; SortBy)
                    {
                        Caption = 'Sort By';
                        Enabled = ShowSort;
                        OptionCaption = 'Qty.,Turnover';

                        ToolTip = 'Specifies the value of the Sort By field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Key"; SortingStigende)
                    {
                        Caption = 'Key';
                        Enabled = ShowSort;
                        OptionCaption = 'Biggest,Smallest';

                        ToolTip = 'Specifies the value of the Key field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Qty"; ShowQty)
                    {
                        Caption = 'Show Quantity';
                        Enabled = ShowSort;

                        ToolTip = 'Specifies the value of the Show Quantity field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            ShowSort := false;
            ShowQty := 20;
        end;
    }

    labels
    {
        Report_Caption = 'Item/Sales Person Top';
        Salesperson_Caption = 'Salesperson';
        Quantity_Caption = 'Quantity';
        SalesAmount_Caption = 'Sales amount';
        Total_Caption = 'Total';
        Page_Caption = 'Page';
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);

        if SortOrder then begin
            TempItemAmount.SetCurrentKey(Amount, "Amount 2", "Item No.");
            case SortingStigende of
                SortingStigende::stigende:
                    TempItemAmount.Ascending(false);
                SortingStigende::faldende:
                    TempItemAmount.Ascending(true);
            end;
        end;
    end;

    var
        CompanyInfo: Record "Company Information";
        TempItemAmount: Record "Item Amount" temporary;
        Salesperson: Record "Salesperson/Purchaser";
        ShowSort: Boolean;
        SortOrder: Boolean;
        CalcAmt: Decimal;
        Qty2: Decimal;
        ShowQty: Integer;
        SortByTxtConst: Label 'Sort By:';
        SortBy: Option "Qty.",Turnover;
        SortingStigende: Option stigende,faldende;
        SalesLCY: Decimal;
        SalesQty: Decimal;
}

