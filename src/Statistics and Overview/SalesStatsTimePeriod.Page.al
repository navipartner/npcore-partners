page 6014591 "NPR Sales Stats Time Period"
{
    // NPR5.52/ZESO/20191010  Object created
    // NPR5.53/ZESO/20191211  CASE 371446 New Function SetGlobals

    Caption = 'Sales Statistics by Date Time';
    PageType = Card;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            group("Start Date & Time")
            {
                Caption = 'Start Date & Time';
                field(StartDate; StartDate)
                {
                    ApplicationArea = All;
                    Caption = 'Start Date';
                    ShowCaption = true;
                }
                field(StartTime; StartTime)
                {
                    ApplicationArea = All;
                    Caption = 'Start Time';
                }
            }
            group("End Date & Time")
            {
                Caption = 'End Date & Time';
                field(EndDate; EndDate)
                {
                    ApplicationArea = All;
                    Caption = 'End Date';
                }
                field(EndTime; EndTime)
                {
                    ApplicationArea = All;
                    Caption = 'End Time';
                }
            }
            group("Filtering Options")
            {
                Caption = 'Filtering Options';
                field(StatisticsBy; StatisticsBy)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Statistics By';
                }
                field(ItemNoFilter; ItemNoFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item No Filter';
                    TableRelation = Item."No.";
                }
                field(ItemGroupFilter; ItemGroupFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item Group Filter';
                    TableRelation = "NPR Item Group" WHERE(Blocked = CONST(false));
                }
                field(ItemCategoryCodeFilter; ItemCategoryCodeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item Category Code Filter';
                    TableRelation = "Item Category";
                }
            }
            part(SaleStatisticsSubform; "NPR Sales Stats Subform")
            {
                Caption = 'Data';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(GetData)
            {
                Caption = 'Get Data';
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    CurrPage.SaleStatisticsSubform.PAGE.PopulateTemp(StartDate, EndDate, StartTime, EndTime, StatisticsBy, ItemNoFilter, ItemCategoryCodeFilter, ItemGroupFilter, Dim1Filter, Dim2Filter);
                    CurrPage.Update;
                end;
            }
        }
    }

    var
        StatisticsBy: Option ,Item,"Item Group","Item Category";
        ItemNoFilter: Code[20];
        ItemGroupFilter: Code[20];
        ItemCategoryCodeFilter: Code[20];
        StartDate: Date;
        StartTime: Time;
        EndDate: Date;
        EndTime: Time;
        QtyQuery: Query "NPR Sales Stat - Item Qty";
        StartDateTime: DateTime;
        EndDateTime: DateTime;
        Dim1Filter: Text;
        Dim2Filter: Text;

    procedure SetGlobals(var InStartDate: Date; var InEndDate: Date; var InStartTime: Time; var InEndTime: Time; var InVarStatisticsBy: Option; var InVarItemFilter: Text; var InVarItemCatFilter: Text; var InVarItemGroupFilter: Text; var InVarDim1Filter: Text; var InVarDim2Filter: Text)
    begin
        //-NPR5.53 [371446]
        InStartDate := StartDate;
        InEndDate := EndDate;
        InStartTime := StartTime;
        InEndTime := EndTime;
        InVarStatisticsBy := StatisticsBy;
        InVarItemFilter := ItemNoFilter;
        InVarItemCatFilter := ItemCategoryCodeFilter;
        InVarItemGroupFilter := ItemGroupFilter;
        InVarDim1Filter := Dim1Filter;
        InVarDim2Filter := Dim2Filter;
        //+NPR5.53 [371446]
    end;
}

