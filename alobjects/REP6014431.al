report 6014431 "Sales Person Trn. by Item Gr."
{
    // NPR70.00.00.00/LS Convert to RTC
    // NPR5.29/JLK /20161122  CASE 254245  Added Filter to SKIP empty Part of Product Line since CALCFIELDS of Turnover filters on No.
    //                                     Variables changed to ENU
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page
    // NPR5.39/TJ  /20180212  CASE 302634 Renamed Name property of controls Sort and SortBy to english
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    DefaultLayout = RDLC;
    RDLCLayout = './Sales Person Trn. by Item Gr..rdlc';

    Caption = 'Sales Person Trn. By Item Gr.';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Item Group";"Item Group")
        {
            CalcFields = "Consumption (Amount)","Sales (Qty.)","Sales (LCY)";
            RequestFilterFields = "No.","Search Description","Date Filter";
            column(COMPANYNAME;CompanyName)
            {
            }
            column(CompanyInfoPicture;CompanyInformation.Picture)
            {
            }
            column(DateFilter;GetFilter("Date Filter"))
            {
            }
            column(SortSalesPerson;SortSalesPerson)
            {
            }
            column(No;"No.")
            {
            }
            column(Description;Description)
            {
            }
            column(SalesQty;"Sales (Qty.)")
            {
                AutoFormatType = 1;
            }
            column(SaleLCY;"Sales (LCY)")
            {
                AutoFormatType = 1;
            }
            column(db;"Sales (LCY)"-"Consumption (Amount)")
            {
                AutoFormatType = 1;
            }
            column(dg;Dg)
            {
                AutoFormatType = 1;
            }
            column(PercentTotalSale;PercentTotalSale)
            {
                AutoFormatType = 1;
            }
            column(TotalSale;TotalSale)
            {
            }
            dataitem("Salesperson/Purchaser";"Salesperson/Purchaser")
            {
                CalcFields = "Sales (Qty.)","Sales (LCY)","COGS (LCY)";
                DataItemLink = "Item Group Filter"=FIELD("No."),"Date Filter"=FIELD("Date Filter");
                column(SalesPersonCode;Code)
                {
                }
                column(SalesPersonName;Name)
                {
                }
                column(SalesPersonSalesQty;"Sales (Qty.)")
                {
                    AutoFormatType = 1;
                }
                column(SalesPersonSalesLcy;"Sales (LCY)")
                {
                    AutoFormatType = 1;
                }
                column(SalesPersonPercentItemGroupSale;PercentItemGroupSale)
                {
                }
                column(SalesPersonDb;"Sales (LCY)"-"COGS (LCY)")
                {
                    AutoFormatType = 1;
                }
                column(SalesPersonDg;Dg)
                {
                    AutoFormatType = 1;
                }

                trigger OnAfterGetRecord()
                begin
                    if "Sales (Qty.)" = 0 then
                      CurrReport.Skip;

                    Clear(Dg);
                    if "Sales (LCY)" <> 0 then
                      Dg := (("Sales (LCY)"-"COGS (LCY)")/"Sales (LCY)")*100;

                    if SortSalesPerson then begin
                      TempVendorAmount.Init;
                      TempVendorAmount."Vendor No." := Code;

                      case Sort of
                        Sort::Highest : Multpl:=-1;
                        Sort::Lowest : Multpl:=1;
                      end;

                      case SortBy of
                        SortBy::Quantity     : TempVendorAmount."Amount (LCY)" := Multpl*"Sales (Qty.)";
                        SortBy::Turnover : TempVendorAmount."Amount (LCY)" := Multpl*"Sales (LCY)";
                        SortBy::DB        : TempVendorAmount."Amount (LCY)" := Multpl*("Sales (LCY)"-"COGS (LCY)");
                      end;
                      TempVendorAmount.Insert;
                    end;

                    Clear(PercentItemGroupSale);
                    if "Item Group"."Sales (LCY)" <>0 then
                      PercentItemGroupSale:='('+Format(("Sales (LCY)"/"Item Group"."Sales (LCY)"*100),-4)+'%)';
                end;

                trigger OnPreDataItem()
                begin
                    TempVendorAmount.DeleteAll;
                end;
            }
            dataitem("Integer";"Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number=FILTER(1..));
                column(IntNumber;Integer.Number)
                {
                }
                column(IntCode;"Salesperson/Purchaser".Code)
                {
                }
                column(IntName;"Salesperson/Purchaser".Name)
                {
                }
                column(IntQty;"Salesperson/Purchaser"."Sales (Qty.)")
                {
                    AutoFormatType = 1;
                }
                column(IntLCY;"Salesperson/Purchaser"."Sales (LCY)")
                {
                    AutoFormatType = 1;
                }
                column(IntPcttekst;PercentItemGroupSale)
                {
                }
                column(IntDb;"Salesperson/Purchaser"."Sales (LCY)"-"Salesperson/Purchaser"."COGS (LCY)")
                {
                    AutoFormatType = 1;
                }
                column(IntDg;Dg)
                {
                    AutoFormatType = 1;
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then begin
                      if not TempVendorAmount.Find('-') then
                        CurrReport.Break;
                      end else
                        if TempVendorAmount.Next = 0 then
                        CurrReport.Break;

                    "Salesperson/Purchaser".Get(TempVendorAmount."Vendor No.");
                    "Salesperson/Purchaser".CalcFields("Sales (Qty.)","Sales (LCY)","COGS (LCY)");

                    Clear(Dg);
                    if "Salesperson/Purchaser"."Sales (LCY)" <> 0 then
                      Dg := (("Salesperson/Purchaser"."Sales (LCY)"-"Salesperson/Purchaser"."COGS (LCY)")/"Salesperson/Purchaser"."Sales (LCY)")*100;

                    Clear(PercentItemGroupSale);
                    if "Item Group"."Sales (LCY)" <> 0 then
                      PercentItemGroupSale := '('+Format(("Salesperson/Purchaser"."Sales (LCY)"/"Item Group"."Sales (LCY)"*100),-4)+'%)';
                end;

                trigger OnPreDataItem()
                begin
                    if (not SortSalesPerson) then CurrReport.Break;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not ShowItemsGrpWithoutSale then begin
                  if "Sales (Qty.)" = 0 then
                    CurrReport.Skip;
                end;

                Clear(Dg);
                if "Sales (LCY)" <> 0 then
                  Dg := (("Sales (LCY)"-"Consumption (Amount)")/"Sales (LCY)")*100;

                Clear(PercentTotalSale);
                if TotalSale <> 0 then
                  PercentTotalSale := ("Sales (LCY)"/TotalSale)*100;
            end;

            trigger OnPreDataItem()
            begin
                CopyFilter("Date Filter", ValueEntry."Posting Date");

                ValueEntry.SetCurrentKey(
                "Item No.","Posting Date","Item Ledger Entry Type","Entry Type","Item Charge No.","Location Code","Variant Code");
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                //-NPR5.29
                ValueEntry.SetFilter(ValueEntry."Item Group No.",'<>%1','');
                //+NPR5.29
                ValueEntry.CalcSums("Sales Amount (Actual)");
                TotalSale := ValueEntry."Sales Amount (Actual)";
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Setting)
                {
                    Caption = 'Setting';
                    field("Show itemgroups with no sales";ShowItemsGrpWithoutSale)
                    {
                        Caption = 'Show Item Groups With No Sales';
                    }
                    field("Sort salespersons";SortSalesPerson)
                    {
                        Caption = 'Sort Salespersons';
                    }
                    field(SortBy;SortBy)
                    {
                        Enabled = sortSalesPerson;
                    }
                    field(Sort;Sort)
                    {
                        Editable = sortSalesPerson;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        Name = 'ConstValue';
        NoCap = 'Item group';
        SalesPersonCap = 'Sales person';
        DescCap = 'Description';
        qtyCap = 'Qty';
        SalesLcyCap = 'Turnover';
        PartPctCap = 'Part %';
        DbCap = 'Margin';
        DgCap = 'Cover-age. (%)';
        TotalSalesCap = '% total sales';
        ReportCap = 'Sales person turnover per item group';
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get;
        CompanyInformation.CalcFields(Picture);
        ShowItemsGrpWithoutSale:=false;
        SortSalesPerson:=false;
        Sort := Sort::Highest;
        SortBy := SortBy::Quantity;

        //-NPR5.39
        // Object.SETRANGE(ID, 6014431);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39
    end;

    var
        CompanyInformation: Record "Company Information";
        Dg: Decimal;
        ShowItemsGrpWithoutSale: Boolean;
        TempVendorAmount: Record "Vendor Amount" temporary;
        [InDataSet]
        SortSalesPerson: Boolean;
        SortBy: Option Quantity,Turnover,DB;
        Sort: Option Highest,Lowest;
        Multpl: Integer;
        PercentItemGroupSale: Text[30];
        TotalSale: Decimal;
        PercentTotalSale: Decimal;
        ValueEntry: Record "Value Entry";
}

