page 6014591 "NPR Sales Stats Time Period"
{
    Caption = 'Sales Statistics by Date Time';
    PageType = Card;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group("Start Date & Time")
            {
                Caption = 'Start Date & Time';
                field(StartDate; StartDate)
                {

                    Caption = 'Start Date';
                    ShowCaption = true;
                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = NPRRetail;
                }
                field(StartTime; StartTime)
                {

                    Caption = 'Start Time';
                    ToolTip = 'Specifies the value of the Start Time field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("End Date & Time")
            {
                Caption = 'End Date & Time';
                field(EndDate; EndDate)
                {

                    Caption = 'End Date';
                    ToolTip = 'Specifies the value of the End Date field';
                    ApplicationArea = NPRRetail;
                }
                field(EndTime; EndTime)
                {

                    Caption = 'End Time';
                    ToolTip = 'Specifies the value of the End Time field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Filtering Options")
            {
                Caption = 'Filtering Options';
                field(StatisticsBy; StatisticsBy)
                {

                    BlankZero = true;
                    Caption = 'Statistics By';
                    OptionCaption = ',Item,Item Category';
                    ToolTip = 'Specifies the value of the Statistics By field';
                    ApplicationArea = NPRRetail;
                }
                field(ItemNoFilter; ItemNoFilter)
                {

                    Caption = 'Item No Filter';
                    TableRelation = Item."No.";
                    ToolTip = 'Specifies the value of the Item No Filter field';
                    ApplicationArea = NPRRetail;
                }
                field(ItemCategoryCodeFilter; ItemCategoryCodeFilter)
                {

                    Caption = 'Item Category Code Filter';
                    TableRelation = "Item Category";
                    ToolTip = 'Specifies the value of the Item Category Code Filter field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(SaleStatisticsSubform; "NPR Sales Stats Subform")
            {
                Caption = 'Data';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Get Data action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    CurrPage.SaleStatisticsSubform.PAGE.PopulateTemp(StartDate, EndDate, StartTime, EndTime, StatisticsBy, ItemNoFilter, ItemCategoryCodeFilter, Dim1Filter, Dim2Filter);
                    CurrPage.Update();
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
        Dim1Filter: Text;
        Dim2Filter: Text;
}

