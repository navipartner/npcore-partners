page 6151073 "NPR Retail Replenishment Setup"
{
    Extensible = False;
    Caption = 'Retail Replenisment Setup';
    PageType = Card;
    SourceTable = "NPR Retail Replenishment Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field("Item Demand Calc. Codeunit"; Rec."Item Demand Calc. Codeunit")
                {

                    TableRelation = AllObjWithCaption."Object ID" where("Object Type" = FILTER(Codeunit));
                    ToolTip = 'Specifies the value of the Item Demand Calc. Codeunit field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Transit Location"; Rec."Default Transit Location")
                {

                    ToolTip = 'Specifies the value of the Default Transit Location field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

