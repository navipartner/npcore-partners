page 6151073 "NPR Retail Replenishment Setup"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj

    Caption = 'Retail Replenisment Setup';
    PageType = Card;
    SourceTable = "NPR Retail Replenishment Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Demand Calc. Codeunit"; "Item Demand Calc. Codeunit")
                {
                    ApplicationArea = All;
                    TableRelation = AllObj."Object ID" WHERE("Object Type" = FILTER(Codeunit));
                    ToolTip = 'Specifies the value of the Item Demand Calc. Codeunit field';
                }
                field("Default Transit Location"; "Default Transit Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Transit Location field';
                }
            }
        }
    }

    actions
    {
    }
}

