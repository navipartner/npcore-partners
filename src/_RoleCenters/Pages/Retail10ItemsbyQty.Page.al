page 6059815 "NPR Retail 10 Items by Qty."
{
    // NC1.17/BHR/20150406 CASE 212983  TOP 10 ITEMS BY QTY SOLD
    // NC1.17/MH/20150619  CASE 216793 Changed pagename
    // NC1.17/BHR/20150619 CASE 216855 Left Padstr the salesQty and add sorting on Low-Level Code
    // NC1.19/BHR/20150720 CASE 218963 Change caption and blank property of sales(Qty)and Actions
    // NC1.20/BHR/20150805 CASE 218620 Applied datefilter and filter on sales(Qty) greater than 0
    // NC1.22/BHR/20160107 CASE 227440 format open proper drilldown page
    // NPR5.23.03/MHA/20160726  CASE 242557 Object renamed and re-versioned from NC1.22 to NPR5.23.03
    // NPR5.29/BHR /20170116 CASE 262956 code to Filter on Specific date

    Caption = 'Top 10 Items by Quantity';
    CardPageID = "Item Card";
    Editable = true;
    PageType = ListPart;
    SourceTable = Item;
    SourceTableTemporary = true;
    SourceTableView = SORTING("Low-Level Code")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            group(Control6014403)
            {
                ShowCaption = false;
                field(StartDate; StartDate)
                {
                    ApplicationArea = All;
                    Caption = 'Start Date';

                    trigger OnValidate()
                    begin
                        //-NPR5.29 [262956]
                        ExecuteQuery;
                        //+NPR5.29 [262956]
                    end;
                }
                field(Enddate; Enddate)
                {
                    ApplicationArea = All;
                    Caption = 'End date';

                    trigger OnValidate()
                    begin
                        //-NPR5.29 [262956]
                        ExecuteQuery;
                        //+NPR5.29 [262956]
                    end;
                }
            }
            group(Control6014400)
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field("No."; "No.")
                    {
                        ApplicationArea = All;

                        trigger OnDrillDown()
                        begin
                            //-NC1.22
                            //PAGE.RUN(PAGE::"Retail Item Card",Rec);
                            Item.Get("No.");
                            PAGE.Run(PAGE::"NPR Retail Item Card", Item);
                            //+NC1.22
                        end;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                    }
                    field("Sales (Qty.)"; "Sales (Qty.)")
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        Caption = 'Sales (Qty.)';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Period Length")
            {
                Caption = 'Period Length';
                Image = CostAccounting;
                Visible = true;
                action(Day)
                {
                    Caption = 'Day';
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Day;
                        UpdateList;
                    end;
                }
                action(Week)
                {
                    Caption = 'Week';
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Week;
                        UpdateList;
                    end;
                }
                action(Month)
                {
                    Caption = 'Month';
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Month;
                        UpdateList;
                    end;
                }
                action(Quarter)
                {
                    Caption = 'Quarter';
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Quarter;
                        UpdateList;
                    end;
                }
                action(Year)
                {
                    Caption = 'Year';
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Year;
                        UpdateList;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        Str: Text[11];
    begin
    end;

    trigger OnOpenPage()
    begin
        PeriodType := PeriodType::Year;
        CurrDate := Today;
        UpdateList;
    end;

    var
        Query1: Query "NPR Retail Top 10 ItemsByQty.";
        Item: Record Item;
        StartDate: Date;
        Enddate: Date;
        Err000: Label 'End Date should be after Start Date';
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        CurrDate: Date;
        SalesQty: Text[30];

    local procedure UpdateList()
    begin
        //-NPR5.29 [262956]
        //DELETEALL;
        //+NPR5.29 [262956]
        Setdate;
        //-NPR5.29 [262956]
        ExecuteQuery;
        //+NPR5.29 [262956]
    end;

    local procedure ExecuteQuery()
    begin
        //+NPR5.29 [262956]
        DeleteAll;
        Query1.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
        Query1.SetFilter(Item_Ledger_Entry_Type, 'Sale');
        Query1.Open;
        while Query1.Read do begin
            if Item.Get(Query1.Item_No) then begin
                TransferFields(Item);
                if Insert then
                    //-NC1.20
                    SetFilter("Date Filter", '%1..%2', StartDate, Enddate);
                //+NC1.20
                //-NC1.17
                //-NC1.20
                //Item.CALCFIELDS("Sales (Qty.)");
                //"Low-Level Code" := ROUND(Item."Sales (Qty.)",0.01) * 100;
                CalcFields("Sales (Qty.)");
                "Low-Level Code" := Round("Sales (Qty.)", 0.01) * 100;
                //+NC1.20
                //+NC1.17
                Modify;
            end;

        end;
        Query1.Close;
    end;

    local procedure Setdate()
    var
        DatePeriod: Record Date;
    begin
        case PeriodType of
            PeriodType::Day:
                begin
                    StartDate := CurrDate;
                    Enddate := CurrDate;
                end;
            PeriodType::Week:
                begin
                    StartDate := CalcDate('<-CW>', CurrDate);
                    Enddate := CalcDate('<CW>', CurrDate);
                end;
            PeriodType::Month:
                begin
                    StartDate := CalcDate('<-CM>', CurrDate);
                    Enddate := CalcDate('<CM>', CurrDate);
                end;
            PeriodType::Quarter:
                begin
                    StartDate := CalcDate('<-CQ>', CurrDate);
                    Enddate := CalcDate('<CQ>', CurrDate);
                end;
            PeriodType::Year:
                begin
                    StartDate := CalcDate('<-CY>', CurrDate);
                    Enddate := CalcDate('<CY>', CurrDate);
                end;
        end;
    end;
}

