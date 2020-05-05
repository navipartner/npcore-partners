report 6014529 "Vendor/Salesperson"
{
    // NPR70.00.00.00/LS/280613 CASE 142565 : COnvert Report to NAV 2013
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on obsolite property CurrReport_PAGENO
    // NPR5.39/TJ  /20180208  CASE 302634 Renamed Name property of controls totalTurnover and totalTotalTurnover
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.54/YAHA/20200603  CASE 394857 Removed Navipartner label
    // NPR5.54/YAHA/20200324  CASE 394883 Removed footer NaviPartner  text
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/VendorSalesperson.rdlc';

    Caption = 'Vendor/Salesperson';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Vendor;Vendor)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(PageNoCaptionLbl;PageNoCaptionLbl)
            {
            }
            column(Report_Caption;Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME;CompanyName)
            {
            }
            column(Salespersonfilter;Salespersonfilter)
            {
            }
            column(VendorFilter;VendorFilter)
            {
            }
            column(No_Vendor;Vendor."No.")
            {
            }
            column(Vendor_Caption;Vendor_Caption_Lbl)
            {
            }
            column(Name_Vendor;Vendor.Name)
            {
            }
            column(No_Caption;No_Caption_Lbl)
            {
            }
            column(Salesperson_Caption;Salesperson_Caption_Lbl)
            {
            }
            column(Turnover_Caption;Turnover_Caption_Lbl)
            {
            }
            column(Cost_Caption;Cost_Caption_Lbl)
            {
            }
            column(DbCaption;DbCaption_Lbl)
            {
            }
            column(CRPct_Caption;CRPct_Caption_Lbl)
            {
            }
            dataitem("Salesperson/Purchaser";"Salesperson/Purchaser")
            {
                PrintOnlyIfDetail = false;
                RequestFilterFields = "Code","Date Filter";

                trigger OnAfterGetRecord()
                begin
                    currentRec += 1;

                    d.Update(2, Round(((currentRec * 10000) / totalRec),1));
                    //-NPR5.39
                    //CurrReport.CREATETOTALS(TotalSale,db);
                    //+NPR5.39

                    TotalSale := 0;
                    TotalCOGS := 0;

                    Item.SetCurrentKey("Vendor No.");
                    Item.SetRange("Vendor No.", Vendor."No.");

                    if Item.Find('-') then
                    repeat
                      SetFilter("Item Filter", Item."No.");
                      CalcFields("Sales (LCY)", "COGS (LCY)");
                      TotalSale += "Sales (LCY)";
                      TotalCOGS += "COGS (LCY)";

                    until Item.Next = 0 else
                    CurrReport.Skip;

                    if TotalSale <> 0 then begin
                    Varegruppetemp.Init;
                    Varegruppetemp."Item No." := "Salesperson/Purchaser".Code;
                    Varegruppetemp.Amount := TotalSale;
                    Varegruppetemp."Amount 2" := TotalCOGS;
                    if Varegruppetemp.Insert then;

                    end else
                    CurrReport.Skip;
                end;

                trigger OnPreDataItem()
                begin
                    Varegruppetemp.DeleteAll();

                    currentRec := 1;
                    totalRec := (Count()*2);
                end;
            }
            dataitem("Integer";"Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number=FILTER(1..));
                column(Item_No_Varegruppetemp;Varegruppetemp."Item No.")
                {
                }
                column(Name_SalesPerson;SalesPerson.Name)
                {
                }
                column(Amount_Varegruppetemp;Varegruppetemp.Amount)
                {
                }
                column(Amount2_Varegruppetemp;Varegruppetemp."Amount 2")
                {
                }
                column(db;db)
                {
                }
                column(dg;dg)
                {
                }
                column(Total_Caption;Total_Caption_Lbl)
                {
                }
                column(turnovertotal;totalTurnover)
                {
                }
                column(forbrugtotal;forbrugtotal)
                {
                }
                column(dbtotal;dbtotal)
                {
                }
                column(dgtotal;dgtotal)
                {
                }
                column(turnoveralt;totalTotalTurnover)
                {
                }
                column(forbrugalt;forbrugalt)
                {
                }
                column(dbalt;dbalt)
                {
                }
                column(dgalt;dgalt)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    dg := 0;
                    db := 0;

                    if Number = 1 then begin
                      if not Varegruppetemp.Find('-') then
                        CurrReport.Break;
                    end else
                      if Varegruppetemp.Next = 0 then
                        CurrReport.Break;

                    if (Varegruppetemp.Amount <> 0) then begin
                    dg := ((Varegruppetemp.Amount-Varegruppetemp."Amount 2")/Varegruppetemp.Amount)*100;
                    db := Varegruppetemp.Amount - Varegruppetemp."Amount 2";
                    end;

                    if SalesPerson.Get(Varegruppetemp."Item No.") then;

                    totalTurnover += Varegruppetemp.Amount;
                    forbrugtotal += Varegruppetemp."Amount 2";
                    dbtotal += db;
                end;

                trigger OnPreDataItem()
                begin
                    Varegruppetemp.Ascending(false);

                    totalTurnover := 0;
                    forbrugtotal := 0;
                    dbtotal := 0;
                    dgtotal := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                d.Update(1,Name);
            end;

            trigger OnPostDataItem()
            begin
                d.Close();
                Clear(d);
            end;

            trigger OnPreDataItem()
            begin
                numberOfSalesPeople := 0;

                d.Open(Text001 + Text002,navn,taeller);
                d.Update(1,'');
                d.Update(2,1);
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
    }

    trigger OnInitReport()
    begin
        firmaoplysninger.Get();
        firmaoplysninger.CalcFields(Picture);

        //-NPR5.39
        // objekt.SETRANGE(ID, 6014529);
        // objekt.SETRANGE(Type, 3);
        // objekt.FIND('-');
        //+NPR5.39

        viskunhovedtal:=false;
        sortSalesPerson:=true;
        visantal:=25;
    end;

    trigger OnPreReport()
    begin
        Salespersonfilter := "Salesperson/Purchaser".GetFilters;
        VendorFilter:=Vendor.GetFilters;
    end;

    var
        firmaoplysninger: Record "Company Information";
        viskunhovedtal: Boolean;
        dg: Decimal;
        sortSalesPerson: Boolean;
        visantal: Integer;
        db: Decimal;
        Salespersonfilter: Text[250];
        Item: Record Item;
        numberOfSalesPeople: Integer;
        Varegruppetemp: Record "Item Amount" temporary;
        TotalSale: Decimal;
        TotalCOGS: Decimal;
        SalesPerson: Record "Salesperson/Purchaser";
        totalTurnover: Decimal;
        forbrugtotal: Decimal;
        dbtotal: Decimal;
        dgtotal: Decimal;
        totalTotalTurnover: Decimal;
        forbrugalt: Decimal;
        dbalt: Decimal;
        dgalt: Decimal;
        d: Dialog;
        currentRec: Integer;
        totalRec: Integer;
        navn: Text[30];
        taeller: Integer;
        Text001: Label 'Creditor: #1################### \';
        Text002: Label '@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        PageNoCaptionLbl: Label 'Page';
        Report_Caption_Lbl: Label 'Vendor/Salesperson';
        VendorFilter: Text[200];
        No_Caption_Lbl: Label 'No.';
        Vendor_Caption_Lbl: Label 'Vendor';
        Salesperson_Caption_Lbl: Label 'Salesperson';
        Turnover_Caption_Lbl: Label 'Turnover';
        Cost_Caption_Lbl: Label 'Cost';
        DbCaption_Lbl: Label 'DB';
        CRPct_Caption_Lbl: Label 'CR%';
        Total_Caption_Lbl: Label 'Total';
}

