report 6014405 "Salesperson/Item Group Top"
{
    // NPR70.00.00.00/LS/051212 CASE143252 : Convert Report to Nav 2013
    // NPR4.18/KN/20150818 CASE 220285 Removed field with 'NAVIPARTNER K�benhavn 2000' caption from footer
    // NPR4.18/LS/20151005 CASE 233997 Modifying report
    // NPR4.21/JLK/20160304  CASE 222741 Hidden Tablix Table_SalesPerson5
    //                                      Added Row Visibility Condition on Tablix102 (Row 3)
    // NPR4.21/LS/20160309  CASE 221836 Redesign Layout/ remove duplicate colum DB/format the header/headings,
    //                                      renamed the report caption/name/displayname from "Sales code/Item group top" to "Salesperson/Item Group Top"
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    DefaultLayout = RDLC;
    RDLCLayout = './SalespersonItem Group Top.rdlc';

    Caption = 'Salesperson/Item Group Top';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Salesperson/Purchaser";"Salesperson/Purchaser")
        {
            CalcFields = "COGS (LCY)","Sales (LCY)";
            RequestFilterFields = "Code","Date Filter","Global Dimension 1 Filter";
            column(COMPANYNAME;CompanyName)
            {
            }
            column(PageCaptionLbl;PageCaptionLbl)
            {
            }
            column(CompanyInfoPicture;CompanyInformation.Picture)
            {
            }
            column(ReportCaption;ReportCaptionLbl)
            {
            }
            column(SalesPersonFilters;"Salesperson/Purchaser".GetFilters)
            {
            }
            column(ItemGroupFilters;"Item Group".GetFilters)
            {
            }
            column(sorteringstext;SortingText)
            {
            }
            column(NoCaption;NoCaptionLbl)
            {
            }
            column(NameCaption;NameCaptionLbl)
            {
            }
            column(TurnoverCaption;TurnoverCaptionLbl)
            {
            }
            column(ProfitCaption;ProfitCaptionLbl)
            {
            }
            column(CRPctCaption;CRPctCaptionLbl)
            {
            }
            column(DBCaption;DBCaptionLbl)
            {
            }
            column(ItemGroupCaption;ItemGroupCaptionLbl)
            {
            }
            column(DescriptionCaption;DescriptionCaptionLbl)
            {
            }
            column(SalesLCYCaption;SalesLCYCaptionLbl)
            {
            }
            column(PctCaption;PctCaptionLbl)
            {
            }
            column(CBCaption;CBCaptionLbl)
            {
            }
            column(Code_SalespersonPurchaser;"Salesperson/Purchaser".Code)
            {
            }
            column(Name_SalespersonPurchaser;"Salesperson/Purchaser".Name)
            {
            }
            column(SalesLCY_SalespersonPurchaser;"Salesperson/Purchaser"."Sales (LCY)")
            {
            }
            column(ProfitLCY_SalespersonPurchaser;"Salesperson/Purchaser"."Sales (LCY)"-"Salesperson/Purchaser"."COGS (LCY)")
            {
            }
            column(ProfitPctSalesperson;ProfitPctSalesperson)
            {
            }
            column(db;db)
            {
            }
            column(ShowMainTotal;ShowMainTotal)
            {
            }
            column(sortSalesPerson;sortSalesPerson)
            {
            }
            column(ShowQty;ShowQty)
            {
            }
            dataitem("Item Group";"Item Group")
            {
                CalcFields = "Sales (LCY)","Consumption (Amount)";
                DataItemLink = "Salesperson Filter"=FIELD(Code),"Date Filter"=FIELD("Date Filter");
                DataItemTableView = SORTING("No.");
                column(No_ItemGroup;"Item Group"."No.")
                {
                }
                column(Description_ItemGroup;"Item Group".Description)
                {
                }
                column(SaleLCY_ItemGroup;"Item Group"."Sales (LCY)")
                {
                }
                column(SalesPct;SalesPct)
                {
                }
                column(CB_ItemGroup;"Item Group"."Sales (LCY)"-"Item Group"."Consumption (Amount)")
                {
                }
                column(dg_ItemGroup;dg)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(dg);
                    Clear(SalesPct);

                    if not("Sales (LCY)" <> 0) then
                      CurrReport.Skip;

                    if not ("Sales (LCY)"<>0) then
                      CurrReport.Skip;

                    if "Sales (LCY)" <> 0 then
                      dg := (("Sales (LCY)"-"Consumption (Amount)")/"Sales (LCY)")*100;

                    if "Salesperson/Purchaser"."Sales (LCY)" <> 0 then
                      SalesPct := ("Sales (LCY)"/"Salesperson/Purchaser"."Sales (LCY)"*100);

                    if sortSalesPerson then begin
                      ItemAmount.Init;
                      ItemAmount.Amount := -"Sales (LCY)";
                      ItemAmount."Amount 2" := "Consumption (Amount)";
                      ItemAmount."Item No." := "No.";
                      ItemAmount.Insert;

                      if (i = 0) or (i < ShowQty) then
                        i := i + 1
                      else begin
                        ItemAmount.Find('+');
                        ItemAmount.Delete;
                      end;
                    end;
                end;
            }
            dataitem("Integer";"Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number=FILTER(1..));
                column(Number_Integer;Integer.Number)
                {
                }
                column(No1_ItemGroup;"Item Group"."No.")
                {
                }
                column(Description1_ItemGroup;"Item Group".Description)
                {
                }
                column(SaleLCY1_ItemGroup;"Item Group"."Sales (LCY)")
                {
                }
                column(SalesPct1;SalesPct)
                {
                }
                column(CB1_ItemGroup;"Item Group"."Sales (LCY)"-"Item Group"."Consumption (Amount)")
                {
                }
                column(dg1_ItemGroup;dg)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (not sortSalesPerson) then
                      CurrReport.Break;

                    if Number = 1 then begin
                      if not ItemAmount.Find('-') then
                        CurrReport.Break;
                    end else
                      if ItemAmount.Next = 0 then
                        CurrReport.Break;

                    "Item Group".Get(ItemAmount."Item No.");
                    "Item Group".CalcFields("Sales (LCY)", "Consumption (Amount)");

                    Clear(dg);
                    Clear(SalesPct);

                    if "Item Group"."Sales (LCY)" <> 0 then
                      dg := (("Item Group"."Sales (LCY)"-"Item Group"."Consumption (Amount)")/"Item Group"."Sales (LCY)")*100;

                    if "Salesperson/Purchaser"."Sales (LCY)" <> 0 then
                      SalesPct := "Item Group"."Sales (LCY)"/"Salesperson/Purchaser"."Sales (LCY)"*100;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                "Item Group".CalcFields("Sales (LCY)");
                ItemAmount.DeleteAll;

                Clear(i);
                Clear(ProfitPctSalesperson);
                Clear(db);

                if "Sales (LCY)" <> 0 then begin
                  ProfitPctSalesperson := (("Sales (LCY)"-"COGS (LCY)")/"Sales (LCY)")*100;
                  db := "Sales (LCY)" - "COGS (LCY)";
                end;

                if  "Sales (LCY)" = 0 then
                  CurrReport.Skip;

                if sortSalesPerson then
                  SortingText := Trans0001
                else
                  SortingText := '';
            end;

            trigger OnPreDataItem()
            begin
                if sortSalesPerson then
                  SortingText := Trans0001
                else
                  SortingText := '';
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowMainTotal;ShowMainTotal)
                    {
                        Caption = 'Show Only Mainfigures';
                        Visible = ShowMainTotalVisible;

                        trigger OnValidate()
                        begin
                            sortSalesPerson := false;
                            sortSalesPersonVisible := false;
                            ShowQtyVisible := false;
                            RequestOptionsPage.Update;
                        end;
                    }
                    field(sortSalesPerson;sortSalesPerson)
                    {
                        Caption = 'Sort Salespersons';
                        Visible = SortSalesPersonVisible;

                        trigger OnValidate()
                        begin
                            if sortSalesPerson then begin
                              ShowMainTotal := false;
                              ShowMainTotalVisible := false;
                              ShowQtyVisible := true;
                            end
                            else begin
                              ShowQtyVisible:=false;
                              ShowMainTotalVisible:=true;
                            end;
                        end;
                    }
                    field(ShowQty;ShowQty)
                    {
                        Caption = 'Show Amounts';
                        Visible = ShowQtyVisible;
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
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);

        //+NPR5.39
        // Object.SETRANGE(ID, 6014405);
        // Object.SETRANGE(Type, 3);
        // //-NPR4.21
        // //Object.FIND('-');
        // Object.FINDFIRST;
        // //+NPR4.21
        //-NPR5.39

        ShowMainTotal := false;
        ShowMainTotalVisible := true;
        sortSalesPerson := true;
        sortSalesPersonVisible := true;
        ShowQtyVisible := true;
        ShowQty := 25;
    end;

    var
        CompanyInformation: Record "Company Information";
        ItemAmount: Record "Item Amount" temporary;
        ShowMainTotal: Boolean;
        ProfitPctSalesperson: Decimal;
        dg: Decimal;
        SalesPct: Decimal;
        sortSalesPerson: Boolean;
        i: Integer;
        ShowQty: Integer;
        SortingText: Text[30];
        db: Decimal;
        Trans0001: Label 'Sorted by turnover';
        PageCaptionLbl: Label 'Page';
        ReportCaptionLbl: Label 'Salesperson/Item Group Top';
        NoCaptionLbl: Label 'No.';
        NameCaptionLbl: Label 'Name';
        TurnoverCaptionLbl: Label 'Turnover';
        ProfitCaptionLbl: Label 'Profit';
        CRPctCaptionLbl: Label 'CR%';
        DBCaptionLbl: Label 'DB';
        ItemGroupCaptionLbl: Label 'Itemgroup';
        DescriptionCaptionLbl: Label 'Description';
        SalesLCYCaptionLbl: Label 'Sales(LCY)';
        PctCaptionLbl: Label '%';
        CBCaptionLbl: Label 'CB';
        [InDataSet]
        ShowMainTotalVisible: Boolean;
        [InDataSet]
        sortSalesPersonVisible: Boolean;
        [InDataSet]
        ShowQtyVisible: Boolean;
}

