page 6151057 "NPR Distribution Header"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Group Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Distribution Headers";
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
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Distribution Lines")
            {
                Caption = 'Distribution Lines';
                Image = List;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Distribution Lines";
                RunPageLink = "Distribution Id" = FIELD("Distribution Id");

                ToolTip = 'Executes the Distribution Lines action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

