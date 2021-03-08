page 6014591 "NPR Sales Stats Time Period"
{
    Caption = 'Sales Statistics by Date Time';
    PageType = Card;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

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
                    ToolTip = 'Specifies the value of the Start Date field';
                }
                field(StartTime; StartTime)
                {
                    ApplicationArea = All;
                    Caption = 'Start Time';
                    ToolTip = 'Specifies the value of the Start Time field';
                }
            }
            group("End Date & Time")
            {
                Caption = 'End Date & Time';
                field(EndDate; EndDate)
                {
                    ApplicationArea = All;
                    Caption = 'End Date';
                    ToolTip = 'Specifies the value of the End Date field';
                }
                field(EndTime; EndTime)
                {
                    ApplicationArea = All;
                    Caption = 'End Time';
                    ToolTip = 'Specifies the value of the End Time field';
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
                    ToolTip = 'Specifies the value of the Statistics By field';
                }
                field(ItemNoFilter; ItemNoFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item No Filter';
                    TableRelation = Item."No.";
                    ToolTip = 'Specifies the value of the Item No Filter field';
                }
                field(ItemCategoryCodeFilter; ItemCategoryCodeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item Category Code Filter';
                    TableRelation = "Item Category";
                    ToolTip = 'Specifies the value of the Item Category Code Filter field';
                }
            }
            part(SaleStatisticsSubform; "NPR Sales Stats Subform")
            {
                Caption = 'Data';
                ApplicationArea = All;
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Get Data action';

                trigger OnAction()
                begin
                    CurrPage.SaleStatisticsSubform.PAGE.PopulateTemp(StartDate, EndDate, StartTime, EndTime, StatisticsBy, ItemNoFilter, ItemCategoryCodeFilter, Dim1Filter, Dim2Filter);
                    CurrPage.Update;
                end;
            }
        }
    }

    var
        StatisticsBy: Option ,Item,"Item Category";
        ItemNoFilter: Code[20];
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
}

