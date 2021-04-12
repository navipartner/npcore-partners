page 6151057 "NPR Distribution Header"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Group Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Distribution Headers";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Group"; Rec."Distribution Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Group field';
                }
                field("Item Hiearachy"; Rec."Item Hiearachy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Hiearachy field';
                }
                field("Distribution Type"; Rec."Distribution Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Type field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Distribution Lines action';
            }
        }
    }
}

