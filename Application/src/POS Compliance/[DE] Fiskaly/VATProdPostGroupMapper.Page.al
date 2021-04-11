page 6014434 "NPR VAT Prod Post Group Mapper"
{

    ApplicationArea = All;
    Caption = 'VAT Prod Post Group Mapper List';
    PageType = List;
    SourceTable = "NPR VAT Prod Post Group Mapper";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("VAT Prod. Pos. Group"; Rec."VAT Prod. Pos. Group")
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