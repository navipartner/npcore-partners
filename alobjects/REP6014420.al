report 6014420 "Item Group Top"
{
    // NPR70.00.00.00/LS Convert Report to Nav 2013
    // NPR5.25/JLK /20160726  CASE 247111 Commented and changed code for Sorting in a more efficient/readable way
    //                                     Corrected the ShowQty and rdlc layout
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on obsolite property CurrReport_PAGENO
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Item Group Top.rdlc';

    Caption = 'Item Group Top';

    dataset
    {
        dataitem("Dimension Value";"Dimension Value")
        {
            DataItemTableView = SORTING(Code,"Global Dimension No.") WHERE("Global Dimension No."=CONST(1));
            column(Picture_CompanyInformation;CompanyInformation.Picture)
            {
            }
            dataitem("Item Group";"Item Group")
            {
                RequestFilterFields = "No.","Belongs In Main Item Group","Date Filter","Salesperson Filter","Vendor Filter","Global Dimension 1 Filter";

                trigger OnAfterGetRecord()
                begin
                    CalcFields("Sales (Qty.)", "Sales (LCY)", "Consumption (Amount)");
                    db := "Sales (LCY)" - "Consumption (Amount)";

                    if "Sales (LCY)" <> 0 then
                      dg := (db/"Sales (LCY)") * 100
                    else
                      dg := 0;
                    //+NPR5.25
                    //CASE ShowType OF
                    //  ShowType::ant :  ItemGroupTemp.Amount := -"Sales (Qty.)";             //Text10600000 :  Varegruppetemp.Amount := -"Sales (Qty.)";
                    //  ShowType::ant :  ItemGroupTemp."Amount 2" := -"Sale (LCY)";          //Text10600000 :  Varegruppetemp."Amount 2" := -"Sale (LCY)";
                    //  ShowType::sal :  ItemGroupTemp.Amount := -"Sale (LCY)";             //Text10600003 :  Varegruppetemp.Amount := -"Sale (LCY)";
                    //  ShowType::sal :  ItemGroupTemp."Amount 2" := -"Sales (Qty.)";     //Text10600003 :  Varegruppetemp."Amount 2" := -"Sales (Qty.)";
                    //  ShowType::db  :  ItemGroupTemp.Amount := -db;                  //Text10600004 :  Varegruppetemp.Amount := -db;
                    //  ShowType::db  :  ItemGroupTemp."Amount 2" := -"Sale (LCY)";    //Text10600004 :  Varegruppetemp."Amount 2" := -"Sale (LCY)";
                    //  ShowType::dg  :  ItemGroupTemp.Amount := -dg;                 //'dg'         : Varegruppetemp.Amount := -dg;
                    //END;

                    //ItemGroupTemp.INSERT;

                    //IF (i = 0) OR (i < ShowQty) THEN
                    //  i := i + 1
                    //ELSE BEGIN
                    //  ItemGroupTemp.FIND('+');
                    //  ItemGroupTemp.DELETE;
                    //END;

                    TempNPRBufferSort.Init;
                    TempNPRBufferSort.Template := "No.";
                    TempNPRBufferSort."Line No." := 0;
                    case SortType of
                      SortType::ant :  begin
                        TempNPRBufferSort."Decimal 1" := "Sales (Qty.)";
                      end;
                      SortType::sal :  begin
                        TempNPRBufferSort."Decimal 1" := "Sales (LCY)";
                      end;
                      SortType::db  :  begin
                        TempNPRBufferSort."Decimal 1" := db;
                      end;
                      SortType::dg  :  begin
                        TempNPRBufferSort."Decimal 1" := dg;
                      end;
                    end;

                    TempNPRBufferSort.Insert;
                    //-NPR5.25
                end;

                trigger OnPreDataItem()
                begin
                    TempNPRBufferSort.DeleteAll;
                    //+NPR5.25
                    //i := 0;
                    TempNPRBufferSort.SetCurrentKey("Decimal 1","Short Code 1");

                    if Sorting = Sorting::st then
                      TempNPRBufferSort.Ascending(false);
                    //-NPR5.25
                    "Item Group".SetFilter("Item Group"."Global Dimension 1 Filter", "Dimension Value".Code);

                    Item.SetFilter("Global Dimension 1 Filter", "Dimension Value".Code);
                    Item.SetRange("Item Group",'');
                    if Item.Find('-') then repeat
                      Item.CalcFields("Sales (Qty.)", "Sales (LCY)");
                      QtyOutside += Item."Sales (Qty.)";
                      SalesOutside += Item."Sales (LCY)";
                    until Item.Next = 0;
                end;
            }
            dataitem("Integer";"Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number=FILTER(1..));
                column(Number_Integer;CountDimValue)
                {
                }
                column(Code_DimensionValue;"Dimension Value".Code)
                {
                }
                column(Name_DimensionValue;"Dimension Value".Name)
                {
                }
                column(No_ItemGroup;"Item Group"."No.")
                {
                }
                column(Description_ItemGroup;"Item Group".Description)
                {
                }
                column(SalesQty_ItemGroup;"Item Group"."Sales (Qty.)")
                {
                }
                column(SaleLCY_ItemGroup;"Item Group"."Sales (LCY)")
                {
                }
                column(db;db)
                {
                }
                column(dg;dg)
                {
                }
                column(QtyOutside;QtyOutside)
                {
                }
                column(SalesOutside;SalesOutside)
                {
                }
                column(COMPANYNAME;CompanyName)
                {
                }
                column(Sorting;Sorting)
                {
                }
                column(SortType;SortType)
                {
                }
                column(decsort;TempNPRBufferSort."Decimal 1")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    //+NPR5.25
                    //IF Number = 1 THEN BEGIN
                    //  IF NOT ItemGroupTemp.FIND('-') THEN
                    //    CurrReport.BREAK;
                    //END
                    //ELSE IF ItemGroupTemp.NEXT = 0 THEN
                    //  CurrReport.BREAK;

                    if Number = 1 then begin
                      if not TempNPRBufferSort.Find('-') then
                        CurrReport.Break;
                    end
                    else if TempNPRBufferSort.Next = 0 then
                      CurrReport.Break;

                    if i > ShowQty then
                      CurrReport.Break;

                    i += 1;
                    //-NPR5.25

                    "Item Group".SetFilter("Item Group"."Global Dimension 1 Filter", "Dimension Value".Code);
                    if "Item Group".Get(TempNPRBufferSort.Template) then
                      "Item Group".CalcFields("Sales (Qty.)","Sales (LCY)", "Consumption (Amount)");

                    db := "Item Group"."Sales (LCY)" - "Item Group"."Consumption (Amount)";
                    if "Item Group"."Sales (LCY)" <> 0 then
                      dg := (db/"Item Group"."Sales (LCY)") * 100
                    else
                      dg := 0;

                    j := IncStr(j);

                    //+NPR5.25
                    if "Dimension Value".Code <> PreviousDimValueCode then begin
                      Clear(CountDimValue);
                      PreviousDimValueCode := "Dimension Value".Code;
                    end;
                    CountDimValue += 1;
                    //-NPR5.25
                end;

                trigger OnPreDataItem()
                begin
                    //-NPR5.39
                    //CurrReport.CREATETOTALS(db,"Item Group"."Sales (LCY)", "Item Group"."Sales (Qty.)");
                    //+NPR5.39
                    //+NPR5.25
                    i := 1;
                    //-NPR5.25
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Clear(QtyOutside);
                Clear(SalesOutside);

                FiltersDimValue := FiltersDimValue + ' ' + "Dimension Value".Code + ' ';

                if Dim1Filter <> '' then begin
                  if "Dimension Value".Code <> Dim1Filter then
                    CurrReport.Skip;
                end;
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
                    field(SortType;SortType)
                    {
                        Caption = 'Show Type';
                        OptionCaption = 'Quantity,Sale(LCY),Contribution Margin,Contribution Ratio';
                    }
                    field(ShowQty;ShowQty)
                    {
                        Caption = 'Show Quantity';
                    }
                    field(Sorting;Sorting)
                    {
                        Caption = 'Sort By';
                        OptionCaption = 'Largest,Smallest';
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
        Report_Caption = 'Item Group Top';
        Sequence_Caption = 'Sequence';
        ItemGroup_Caption = 'Item Group';
        Description_Caption = 'Description';
        Quantity_Caption = 'Quantity';
        Sale_LCY_Caption = 'Sale (LCY)';
        Profit_LCY_Caption = 'Profit (LCY)';
        Profit_Pct_Caption = 'Profit %';
        Ikke_Caption = 'Not in item group';
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        SortType := SortType::ant;
        ShowQty := 20;
        Sorting := Sorting::st;

        //-NPR5.39
        // Object.SETRANGE(ID, 6014420);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39
    end;

    trigger OnPreReport()
    begin
        j := '2';

        Clear(TotalQty);
        Clear(TotalSale);
        Clear(TotalProfit);

        Dim1Filter := "Item Group".GetFilter("Global Dimension 1 Filter");
    end;

    var
        i: Integer;
        SortType: Option ant,sal,db,dg;
        window: Dialog;
        ShowQty: Integer;
        CompanyInformation: Record "Company Information";
        db: Decimal;
        dg: Decimal;
        Sorting: Option st,mi;
        j: Text[30];
        Item: Record Item;
        QtyOutside: Decimal;
        SalesOutside: Decimal;
        TotalQty: Decimal;
        TotalSale: Decimal;
        TotalProfit: Decimal;
        Dim1Filter: Text[30];
        Text10600000: Label 'ant';
        Text10600001: Label 'st';
        Text10600002: Label 'Itemgroups Sorted by #1##########';
        Text10600003: Label 'sal';
        Text10600004: Label 'db';
        PreviousDimValueCode: Code[20];
        CountDimValue: Integer;
        TempNPRBufferSort: Record "NPR - TEMP Buffer" temporary;
        FiltersDimValue: Text;
}

