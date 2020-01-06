page 6014591 "Sales Statistics Time Period"
{
    // NPR5.52/ZESO/20191010  Object created

    Caption = 'Sales Statistics by Date Time';
    PageType = Card;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            group("Start Date & Time ")
            {
                Caption = 'Start Date & Time';
                field(StartDate;StartDate)
                {
                    Caption = 'Start Date';
                    ShowCaption = true;
                }
                field(StartTime;StartTime)
                {
                    Caption = 'Start Time';
                }
            }
            group("End Date & Time")
            {
                Caption = 'End Date & Time';
                field(EndDate;EndDate)
                {
                    Caption = 'End Date';
                }
                field(EndTime;EndTime)
                {
                    Caption = 'End Time';
                }
            }
            group("Filtering Options")
            {
                Caption = 'Filtering Options';
                field(StatisticsBy;StatisticsBy)
                {
                    BlankZero = true;
                    Caption = 'Statistics By';
                }
                field(ItemNoFilter;ItemNoFilter)
                {
                    Caption = 'Item No Filter';
                    TableRelation = Item."No.";
                }
                field(ItemGroupFilter;ItemGroupFilter)
                {
                    Caption = 'Item Group Filter';
                    TableRelation = "Item Group" WHERE (Blocked=CONST(false));
                }
                field(ItemCategoryCodeFilter;ItemCategoryCodeFilter)
                {
                    Caption = 'Item Category Code Filter';
                    TableRelation = "Item Category";
                }
            }
            part(SaleStatisticsSubform;"Sales Statistics Subform")
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
                    CurrPage.SaleStatisticsSubform.PAGE.PopulateTemp(StartDate,EndDate,StartTime,EndTime,StatisticsBy,ItemNoFilter,ItemCategoryCodeFilter,ItemGroupFilter,Dim1Filter,Dim2Filter);
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
        QtyQuery: Query "Sales Statistics - Item Qty";
        StartDateTime: DateTime;
        EndDateTime: DateTime;
        Dim1Filter: Text;
        Dim2Filter: Text;
}

