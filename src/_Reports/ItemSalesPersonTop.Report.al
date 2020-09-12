report 6014474 "NPR Item/Sales Person Top"
{
    // NPR70.00.00.00/LS/280613 CASE  162050  Convert Report to Nav 2013
    // NPR4.21/LS/20160216  CASE 234832 Correct report's variables/codes/code indentation/dataset names/Report layout
    // NPR5.36/TJ/20170927  CASE 286283 Renamed options with danish specific letters to english words
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on obsolite property CurrReport_PAGENO
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/ItemSales Person Top.rdlc';

    Caption = 'Item/Sales Person Top';

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
            column(SortHeading_Item; SortByTxtConst + ' ' + Format(SortBy) + ' ' + Format(Key))
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
            column(Sorting_Item; Sorting)
            {
            }
            column(SortBy_Item; SortBy)
            {
            }
            dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
            {
                CalcFields = "NPR Sales (LCY)", "NPR Sales (Qty.)";
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
                column(SalesLCY_SalespersonPurchaser; "Salesperson/Purchaser"."NPR Sales (LCY)")
                {
                }
                column(SalesQty_SalespersonPurchaser; "Salesperson/Purchaser"."NPR Sales (Qty.)")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if "NPR Sales (LCY)" = 0 then CurrReport.Skip;

                    if Sorting then begin
                        ItemAmount."Item No." := Code;

                        case SortBy of
                            SortBy::Turnover:
                                begin
                                    ItemAmount.Amount := Abs("NPR Sales (LCY)");
                                    ItemAmount."Amount 2" := Abs("NPR Sales (Qty.)");
                                end;
                            SortBy::"Qty.":
                                begin
                                    ItemAmount.Amount := Abs("NPR Sales (Qty.)");
                                    ItemAmount."Amount 2" := Abs("NPR Sales (LCY)");
                                end;
                        end;
                        ItemAmount.Insert;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    if Sorting then
                        ItemAmount.DeleteAll;

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
                        if not ItemAmount.FindFirst then
                            CurrReport.Break;
                    end else
                        if ItemAmount.Next = 0 then
                            CurrReport.Break;

                    if Salesperson.Get(ItemAmount."Item No.") then;

                    Clear(CalcAmt);
                    Clear(Qty2);

                    case SortBy of
                        SortBy::Turnover:
                            begin
                                CalcAmt := ItemAmount.Amount;
                                Qty2 := ItemAmount."Amount 2";
                            end;
                        SortBy::"Qty.":
                            begin
                                Qty2 := ItemAmount.Amount;
                                CalcAmt := ItemAmount."Amount 2";
                            end;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    if not Sorting then CurrReport.Break;
                    //-NPR5.39
                    //CurrReport.CREATETOTALS(antal2,amountCalc);
                    //+NPR5.39
                    SetRange(Number, 1, ShowQty);
                end;
            }

            trigger OnPreDataItem()
            begin
                //-NPR5.39
                //CurrReport.CREATETOTALS(antal2,amountCalc);
                //CurrReport.CREATETOTALS("Salesperson/Purchaser"."Sales (Qty.)","Salesperson/Purchaser"."Sales (LCY)");
                //+NPR5.39
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group("Option")
                {
                    field("Sorting"; Sorting)
                    {
                        Caption = 'Sorting';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            //-NPK7
                            ShowSort := false;
                            ShowSort := Sorting;
                            //+NPK7
                        end;
                    }
                    field(SortBy; SortBy)
                    {
                        Caption = 'Sort By';
                        Enabled = ShowSort;
                        OptionCaption = 'Qty.,Turnover';
                        ApplicationArea = All;
                    }
                    field("Key"; Key)
                    {
                        Caption = 'Key';
                        Enabled = ShowSort;
                        OptionCaption = 'Biggest,Smallest';
                        ApplicationArea = All;
                    }
                    field(ShowQty; ShowQty)
                    {
                        Caption = 'Show Qty.';
                        Enabled = ShowSort;
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            //-NPK7
            ShowSort := false;
            ShowQty := 20;
            //+NPK7
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

        //-NPR5.39
        // Object.SETRANGE(ID, 6014474);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39

        if Sorting then begin
            ItemAmount.SetCurrentKey(Amount, "Amount 2", "Item No.");
            case Key of
                Key::stigende:
                    ItemAmount.Ascending(false);
                Key::faldende:
                    ItemAmount.Ascending(true);
            end;
        end;
    end;

    var
        ItemAmount: Record "Item Amount" temporary;
        Sorting: Boolean;
        Salesperson: Record "Salesperson/Purchaser";
        SortBy: Option "Qty.",Turnover;
        "Key": Option stigende,faldende;
        CompanyInfo: Record "Company Information";
        ShowQty: Integer;
        Qty2: Decimal;
        CalcAmt: Decimal;
        [InDataSet]
        ShowSort: Boolean;
        SortByTxtConst: Label 'Sort By:';
}

