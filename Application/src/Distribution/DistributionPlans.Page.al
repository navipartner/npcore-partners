page 6151063 "NPR Distribution Plans"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Plans';
    CardPageID = "NPR Distribution Plan";
    PageType = List;
    SourceTable = "NPR Distribution Headers";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Group"; Rec."Distribution Group")
                {

                    ToolTip = 'Specifies the value of the Distribution Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Hiearachy"; Rec."Item Hiearachy")
                {

                    ToolTip = 'Specifies the value of the Item Hiearachy field';
                    ApplicationArea = NPRRetail;
                }
                field("Distribution Type"; Rec."Distribution Type")
                {

                    ToolTip = 'Specifies the value of the Distribution Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Required Date"; Rec."Required Date")
                {

                    ToolTip = 'Specifies the value of the Required Date field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

