page 6014591 "NPR Sales Stats Time Period"
{
    Extensible = true;
    Caption = 'Sales Statistics by Date';
    PageType = Card;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group("Start & End Date")
            {
                Caption = 'Start & End Date';
                field(StartDate; StartDate)
                {
                    Caption = 'Start Date';
                    ShowCaption = true;
                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = NPRRetail;
                }
                field(EndDate; EndDate)
                {
                    Caption = 'End Date';
                    ToolTip = 'Specifies the value of the End Date field';
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
                    CurrPage.SaleStatisticsSubform.PAGE.PopulateTemp(StartDate, EndDate, StatisticsBy, ItemNoFilter, ItemCategoryCodeFilter, Dim1Filter, Dim2Filter);
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
        EndDate: Date;
        Dim1Filter: Text;
        Dim2Filter: Text;

    procedure GetGlobals(var _StartDate: Date; var _EndDate: Date; var _StatisticsBy: Option; var _ItemFilter: Text[20]; var _ItemCatFilter: Text[20];
                         var _Dim1Filter: Text[20]; var _Dim2Filter: Text[20])
    begin
        _StartDate := StartDate;
        _EndDate := EndDate;
        _StatisticsBy := StatisticsBy;
        _ItemFilter := ItemNoFilter;
        _ItemCatFilter := ItemCategoryCodeFilter;
        _Dim1Filter := CopyStr(Dim1Filter, 1, MaxStrLen(_Dim1Filter));
        _Dim2Filter := CopyStr(Dim2Filter, 1, MaxStrLen(_Dim2Filter));
    end;
}