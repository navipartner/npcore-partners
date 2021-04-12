page 6184505 "NPR EFT Shopper Recognition"
{
    // NPR5.49/MMV /20190410 CASE 347476 Created object

    Caption = 'EFT Shopper Recognition';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR EFT Shopper Recognition";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Integration Type"; Rec."Integration Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Integration Type field';
                }
                field("Shopper Reference"; Rec."Shopper Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopper Reference field';
                }
                field("Contract ID"; Rec."Contract ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contract ID field';
                }
                field("Contract Type"; Rec."Contract Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contract Type field';
                }
                field("Entity Type"; Rec."Entity Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entity Type field';
                }
                field("Entity Key"; Rec."Entity Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entity Key field';
                }
            }
        }
    }

    actions
    {
    }
}

