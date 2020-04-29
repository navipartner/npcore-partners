page 6059817 "Retail Top 10 Salesperson"
{
    // NC1.20/BHR/20150928 CASE 223709 Object created
    // NC1.22/JDH/20160202 CASE 233311 DK caption changed for page
    // NC1.22/BHR/20160107 CASE 227440 format of "Search E-Mail" to enable proper sorting.
    // NC1.22.01/TS/20160518  CASE 241345  Move fields to the right
    // NPR5.23.03/MHA/20160726  CASE 242557 Object renamed and re-versioned from NC1.22 to NPR5.23.03
    // NPR5.26/TS/20160825  CASE 249961 Removed Field Search Email
    // NPR5.29/BHR /20170116 CASE 262956 code to Filter on Specific date

    Caption = 'Top 10 Sales Persons';
    CardPageID = "Salesperson Card";
    Editable = true;
    PageType = ListPart;
    SourceTable = "Salesperson/Purchaser";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Search E-Mail")
                      ORDER(Descending)
                      WHERE("Sales (Qty.)"=FILTER(<>0));

    layout
    {
        area(content)
        {
            group(Control6014404)
            {
                ShowCaption = false;
                field(StartDate;StartDate)
                {
                    Caption = 'Start Date';

                    trigger OnValidate()
                    begin
                        //-NPR5.29 [262956]
                        ExecuteQuery;
                        //+NPR5.29 [262956]
                    end;
                }
                field(Enddate;Enddate)
                {
                    Caption = 'End date';

                    trigger OnValidate()
                    begin
                        //-NPR5.29 [262956]
                        ExecuteQuery;
                        //+NPR5.29 [262956]
                    end;
                }
            }
            group(Control6014401)
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field("Code";Code)
                    {

                        trigger OnDrillDown()
                        begin
                            //-NC1.22
                            //PAGE.RUN(6014428,REC);
                            SalesPerson.Get(Code);
                            PAGE.Run(PAGE::"Salesperson Card",SalesPerson);
                            //+NC1.22
                        end;
                    }
                    field(Name;Name)
                    {
                    }
                    field("Sales (Qty.)";"Sales (Qty.)")
                    {
                    }
                    field("Sales (LCY)";"Sales (LCY)")
                    {
                        BlankZero = true;
                        Caption = 'Sales Amount (Actual)';
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

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Day;
                        UpdateList;
                    end;
                }
                action(Week)
                {
                    Caption = 'Week';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Week ;
                        UpdateList;
                    end;
                }
                action(Month)
                {
                    Caption = 'Month';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Month;
                        UpdateList;
                    end;
                }
                action(Quarter)
                {
                    Caption = 'Quarter';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Quarter;
                        UpdateList;
                    end;
                }
                action(Year)
                {
                    Caption = 'Year';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Year;
                        UpdateList;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        PeriodType := PeriodType::Year;
        CurrDate := Today;
        UpdateList;
    end;

    var
        Query1: Query "Retail Top 10 SalesPersons";
        SalesPerson: Record "Salesperson/Purchaser";
        StartDate: Date;
        Enddate: Date;
        Err000: Label 'End Date should be after Start Date';
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        CurrDate: Date;

    local procedure UpdateList()
    begin
        //-NPR5.29 [262956]
        //DELETEALL;
        //-NPR5.29 [262956]
        Setdate;
        //-NPR5.29 [262956]
        ExecuteQuery;
        //-NPR5.29 [262956]
    end;

    local procedure ExecuteQuery()
    begin
        //-NPR5.29 [262956]
        DeleteAll;
        //-NPR5.29 [262956]
        Clear(Query1);
        Query1.SetFilter(Query1.Date_Filter,'%1..%2',StartDate,Enddate);
        Query1.Open;
        while Query1.Read do begin
          SalesPerson.Get(Query1.Code);
          TransferFields(SalesPerson);
          //-NC1.22
          if Insert then;
          //+NC1.22
          SetFilter("Date Filter",'%1..%2',StartDate,Enddate);
          CalcFields("Sales (Qty.)");

          //-NC1.22
          //"Search E-Mail" := FORMAT(ROUND("Sales (Qty.)",0.01) * 100);
          "Search E-Mail" := Format(Round(-"Sales (Qty.)",0.01) * 100,20,1);
          "Search E-Mail" := PadStr('',15 - StrLen("Search E-Mail"),'0') + "Search E-Mail";
          Modify;
          //+NC1.22
        end;
         Query1.Close;
    end;

    local procedure Setdate()
    var
        DatePeriod: Record Date;
    begin
        case PeriodType of
          PeriodType::Day :
           begin
            StartDate := CurrDate;
            Enddate := CurrDate;
           end;
          PeriodType::Week :
           begin
            StartDate := CalcDate('<-CW>',CurrDate);
            Enddate := CalcDate('<CW>',CurrDate);
           end;
          PeriodType::Month :
           begin
            StartDate := CalcDate('<-CM>',CurrDate);
            Enddate := CalcDate('<CM>',CurrDate);
           end;
          PeriodType::Quarter :
          begin
            StartDate := CalcDate('<-CQ>',CurrDate);
            Enddate := CalcDate('<CQ>',CurrDate);
          end;
          PeriodType::Year :
          begin
            StartDate := CalcDate('<-CY>',CurrDate);
            Enddate := CalcDate('<CY>',CurrDate);
          end;
        end;
    end;
}

