report 6014405 "NPR Salesperson/Item Group Top"
{
    // NPR70.00.00.00/LS/051212 CASE143252 : Convert Report to Nav 2013
    // NPR4.18/KN/20150818 CASE 220285 Removed field with 'NAVIPARTNER K¢benhavn 2000' caption from footer
    // NPR4.18/LS/20151005 CASE 233997 Modifying report
    // NPR4.21/JLK/20160304  CASE 222741 Hidden Tablix Table_SalesPerson5
    //                                      Added Row Visibility Condition on Tablix102 (Row 3)
    // NPR4.21/LS/20160309  CASE 221836 Redesign Layout/ remove duplicate colum DB/format the header/headings,
    //                                      renamed the report caption/name/displayname from "Sales code/Item group top" to "Salesperson/Item Group Top"
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.54/YAHA/20200306 CASE  394854 Set Visibility to FALSE for logo
    // NPR5.55/ANPA/20200505  CASE 402933 Added more space to the CompanyName
    // NPR5.55/BHR /20200414  CASE 361515 Rework report to remove use of Flowfields
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/SalespersonItem Group Top.rdlc';

    Caption = 'Salesperson/Item Group Top';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
        {
            CalcFields = "NPR COGS (LCY)", "NPR Sales (LCY)";
            RequestFilterFields = "Code", "Date Filter", "NPR Global Dimension 1 Filter";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(PageCaptionLbl; PageCaptionLbl)
            {
            }
            column(CompanyInfoPicture; CompanyInformation.Picture)
            {
            }
            column(ReportCaption; ReportCaptionLbl)
            {
            }
            column(SalesPersonFilters; "Salesperson/Purchaser".GetFilters)
            {
            }
            column(ItemGroupFilters; "Item Group".GetFilters)
            {
            }
            column(sorteringstext; SortingText)
            {
            }
            column(NoCaption; NoCaptionLbl)
            {
            }
            column(NameCaption; NameCaptionLbl)
            {
            }
            column(TurnoverCaption; TurnoverCaptionLbl)
            {
            }
            column(ProfitCaption; ProfitCaptionLbl)
            {
            }
            column(CRPctCaption; CRPctCaptionLbl)
            {
            }
            column(DBCaption; DBCaptionLbl)
            {
            }
            column(ItemGroupCaption; ItemGroupCaptionLbl)
            {
            }
            column(DescriptionCaption; DescriptionCaptionLbl)
            {
            }
            column(SalesLCYCaption; SalesLCYCaptionLbl)
            {
            }
            column(PctCaption; PctCaptionLbl)
            {
            }
            column(CBCaption; CBCaptionLbl)
            {
            }
            column(Code_SalespersonPurchaser; "Salesperson/Purchaser".Code)
            {
            }
            column(Name_SalespersonPurchaser; "Salesperson/Purchaser".Name)
            {
            }
            column(SalesLCY_SalespersonPurchaser; SalesLCY)
            {
            }
            column(ProfitLCY_SalespersonPurchaser; SalesLCY - CogsLCY)
            {
            }
            column(ProfitPctSalesperson; ProfitPctSalesperson)
            {
            }
            column(db; db)
            {
            }
            column(ShowMainTotal; ShowMainTotal)
            {
            }
            column(sortSalesPerson; sortSalesPerson)
            {
            }
            column(ShowQty; ShowQty)
            {
            }
            dataitem("Item Group"; "NPR Item Group")
            {
                CalcFields = "Sales (LCY)", "Consumption (Amount)";
                DataItemLink = "Salesperson Filter" = FIELD(Code), "Date Filter" = FIELD("Date Filter");
                DataItemTableView = SORTING("No.");
                column(No_ItemGroup; "Item Group"."No.")
                {
                }
                column(Description_ItemGroup; "Item Group".Description)
                {
                }
                column(SaleLCY_ItemGroup; SalesLCYGP)
                {
                }
                column(SalesPct; SalesPct)
                {
                }
                column(CB_ItemGroup; SalesLCYGP - CogsLCYGP)
                {
                }
                column(dg_ItemGroup; dg)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(dg);
                    Clear(SalesPct);

                    //-NPR5.55 [361515]
                    SalesLCYGP := 0;
                    CogsLCYGP := 0;
                    ValueEntryGP.Reset;
                    ValueEntryGP.SetRange("Item Ledger Entry Type", ValueEntryGP."Item Ledger Entry Type"::Sale);
                    ValueEntryGP.SetRange("Salespers./Purch. Code", "Salesperson/Purchaser".Code);
                    ValueEntryGP.SetRange("NPR Item Group No.", "Item Group"."No.");
                    ValueEntryGP.SetFilter("Posting Date", SPDateFilter);
                    ValueEntryGP.SetFilter("Global Dimension 1 Code", SPGlobalDim1Filter);

                    if ValueEntryGP.FindSet then
                        repeat
                            SalesLCYGP += ValueEntryGP."Sales Amount (Actual)";
                            CogsLCYGP += -ValueEntryGP."Cost Amount (Actual)";
                        until ValueEntryGP.Next = 0;

                    // IF NOT("Sales (LCY)" <> 0) THEN
                    //  CurrReport.SKIP;
                    //
                    // IF NOT ("Sales (LCY)"<>0) THEN
                    //  CurrReport.SKIP;
                    //
                    // IF "Sales (LCY)" <> 0 THEN
                    //  dg := (("Sales (LCY)"-"Consumption (Amount)")/"Sales (LCY)")*100;
                    //
                    // IF "Salesperson/Purchaser"."Sales (LCY)" <> 0 THEN
                    //  SalesPct := ("Sales (LCY)"/"Salesperson/Purchaser"."Sales (LCY)"*100);
                    if SalesLCYGP = 0 then
                        CurrReport.Skip;

                    if SalesLCYGP <> 0 then
                        dg := ((SalesLCYGP - CogsLCYGP) / SalesLCYGP) * 100;

                    if SalesLCY <> 0 then
                        SalesPct := (SalesLCYGP / SalesLCY * 100);
                    //+NPR5.55 [361515]
                    if sortSalesPerson then begin
                        ItemAmount.Init;
                        //-NPR5.55 [361515]
                        //ItemAmount.Amount := -"Sales (LCY)";
                        ItemAmount.Amount := -SalesLCYGP;
                        //+NPR5.55 [361515]
                        ItemAmount."Amount 2" := CogsLCYGP;
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

                trigger OnPreDataItem()
                begin
                    //-NPR5.55 [361515]
                    "Item Group".SetFilter("No.", SPItemGroupFilter);
                    //+NPR5.55 [361515]
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(Number_Integer; Integer.Number)
                {
                }
                column(No1_ItemGroup; "Item Group"."No.")
                {
                }
                column(Description1_ItemGroup; "Item Group".Description)
                {
                }
                column(SaleLCY1_ItemGroup; SalesLCYGPINT)
                {
                }
                column(SalesPct1; SalesPct)
                {
                }
                column(CB1_ItemGroup; SalesLCYGPINT - CogsLCYGPINT)
                {
                }
                column(dg1_ItemGroup; dg)
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

                    //-NPR5.55 [361515]
                    "Item Group".Get(ItemAmount."Item No.");
                    //"Item Group".CALCFIELDS("Sales (LCY)", "Consumption (Amount)");
                    SalesLCYGPINT := 0;
                    CogsLCYGPINT := 0;
                    ValueEntryGP.Reset;
                    ValueEntryGP.SetRange("Item Ledger Entry Type", ValueEntryGP."Item Ledger Entry Type"::Sale);
                    ValueEntryGP.SetRange("Salespers./Purch. Code", "Salesperson/Purchaser".Code);
                    ValueEntryGP.SetRange("NPR Item Group No.", ItemAmount."Item No.");
                    ValueEntryGP.SetFilter("Posting Date", SPDateFilter);
                    ValueEntryGP.SetFilter("Global Dimension 1 Code", SPGlobalDim1Filter);
                    if ValueEntryGP.FindSet then
                        repeat
                            SalesLCYGPINT += ValueEntryGP."Sales Amount (Actual)";
                            CogsLCYGPINT += -ValueEntryGP."Cost Amount (Actual)";
                        until ValueEntryGP.Next = 0;


                    Clear(dg);
                    Clear(SalesPct);

                    // IF "Item Group"."Sales (LCY)" <> 0 THEN
                    //  dg := (("Item Group"."Sales (LCY)"-"Item Group"."Consumption (Amount)")/"Item Group"."Sales (LCY)")*100;
                    //
                    // IF "Salesperson/Purchaser"."Sales (LCY)" <> 0 THEN
                    //  SalesPct := "Item Group"."Sales (LCY)"/"Salesperson/Purchaser"."Sales (LCY)"*100;
                    if SalesLCYGPINT <> 0 then
                        dg := ((SalesLCYGPINT - CogsLCYGPINT) / SalesLCYGPINT) * 100;

                    if SalesLCY <> 0 then
                        SalesPct := SalesLCYGPINT / SalesLCY * 100;
                    //+NPR5.55 [361515]
                end;
            }

            trigger OnAfterGetRecord()
            begin
                //-NPR5.55 [361515]
                SalesLCY := 0;
                CogsLCY := 0;
                ValueEntry.Reset;
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.SetRange("Salespers./Purch. Code", "Salesperson/Purchaser".Code);
                CopyFilter("Date Filter", ValueEntry."Posting Date");
                CopyFilter("NPR Item Group Filter", ValueEntry."NPR Item Group No.");
                CopyFilter("NPR Global Dimension 1 Filter", ValueEntry."Global Dimension 1 Code");

                if ValueEntry.FindSet then
                    repeat
                        SalesLCY += ValueEntry."Sales Amount (Actual)";
                        CogsLCY += -ValueEntry."Cost Amount (Actual)"
                    until ValueEntry.Next = 0;
                //  "Item Group".CALCFIELDS("Sales (LCY)");
                //+NPR5.55 [361515]


                ItemAmount.DeleteAll;

                Clear(i);
                Clear(ProfitPctSalesperson);
                Clear(db);
                //-NPR5.55 [361515]
                // IF "Sales (LCY)" <> 0 THEN BEGIN
                //  ProfitPctSalesperson := (("Sales (LCY)"-"COGS (LCY)")/"Sales (LCY)")*100;
                //  db := "Sales (LCY)" - "COGS (LCY)";
                // END;
                //
                // IF  "Sales (LCY)" = 0 THEN
                //  CurrReport.SKIP;

                if SalesLCY <> 0 then begin
                    ProfitPctSalesperson := ((SalesLCY - CogsLCY) / SalesLCY) * 100;
                    db := SalesLCY - CogsLCY;
                end;

                if SalesLCY = 0 then
                    CurrReport.Skip;

                //+NPR5.55 [361515]

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
                //-NPR5.55 [361515]
                SPDateFilter := "Salesperson/Purchaser".GetFilter("Date Filter");
                SPGlobalDim1Filter := "Salesperson/Purchaser".GetFilter("Global Dimension 1 Code");
                SPItemGroupFilter := "Salesperson/Purchaser".GetFilter("NPR Item Group Filter");
                //+NPR5.55 [361515]
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
                    field(ShowMainTotal; ShowMainTotal)
                    {
                        Caption = 'Show Only Mainfigures';
                        Visible = ShowMainTotalVisible;
                        ApplicationArea=All;

                        trigger OnValidate()
                        begin
                            sortSalesPerson := false;
                            sortSalesPersonVisible := false;
                            ShowQtyVisible := false;
                            RequestOptionsPage.Update;
                        end;
                    }
                    field(sortSalesPerson; sortSalesPerson)
                    {
                        Caption = 'Sort Salespersons';
                        Visible = SortSalesPersonVisible;
                        ApplicationArea=All;

                        trigger OnValidate()
                        begin
                            if sortSalesPerson then begin
                                ShowMainTotal := false;
                                ShowMainTotalVisible := false;
                                ShowQtyVisible := true;
                            end
                            else begin
                                ShowQtyVisible := false;
                                ShowMainTotalVisible := true;
                            end;
                        end;
                    }
                    field(ShowQty; ShowQty)
                    {
                        Caption = 'Show Amounts';
                        Visible = ShowQtyVisible;
                        ApplicationArea=All;
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
        ValueEntry: Record "Value Entry";
        SalesLCY: Decimal;
        CogsLCY: Decimal;
        ConsumptionAmt: Decimal;
        ValueEntryGP: Record "Value Entry";
        SalesLCYGP: Decimal;
        CogsLCYGP: Decimal;
        ConsumptionAmtGP: Decimal;
        SalesLCYGPINT: Decimal;
        CogsLCYGPINT: Decimal;
        ConsumptionAmtINT: Decimal;
        SPDateFilter: Text;
        SPGlobalDim1Filter: Text;
        SPItemGroupFilter: Text;
}

