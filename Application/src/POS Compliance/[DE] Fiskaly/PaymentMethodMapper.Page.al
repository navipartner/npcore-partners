page 6014433 "NPR Payment Method Mapper"
{

    ApplicationArea = All;
    Caption = 'Payment Method Mapper';
    PageType = List;
    SourceTable = "NPR Payment Method Mapper";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("POS Payment Method"; Rec."POS Payment Method")
                {
                    ApplicationArea = All;
                }
                field("Fiscal Name"; Rec."Fiscal Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}