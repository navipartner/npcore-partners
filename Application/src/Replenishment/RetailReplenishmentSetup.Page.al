page 6151073 "NPR Retail Replenishment Setup"
{
    Caption = 'Retail Replenisment Setup';
    PageType = Card;
    SourceTable = "NPR Retail Replenishment Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Item Demand Calc. Codeunit"; Rec."Item Demand Calc. Codeunit")
                {
                    ApplicationArea = All;
                    TableRelation = AllObjWithCaption."Object ID" where("Object Type" = FILTER(Codeunit));
                    ToolTip = 'Specifies the value of the Item Demand Calc. Codeunit field';
                }
                field("Default Transit Location"; Rec."Default Transit Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Transit Location field';
                }
            }
        }
    }
}

