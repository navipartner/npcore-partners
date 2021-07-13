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
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Integration Type"; Rec."Integration Type")
                {

                    ToolTip = 'Specifies the value of the Integration Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Shopper Reference"; Rec."Shopper Reference")
                {

                    ToolTip = 'Specifies the value of the Shopper Reference field';
                    ApplicationArea = NPRRetail;
                }
                field("Contract ID"; Rec."Contract ID")
                {

                    ToolTip = 'Specifies the value of the Contract ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Contract Type"; Rec."Contract Type")
                {

                    ToolTip = 'Specifies the value of the Contract Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Entity Type"; Rec."Entity Type")
                {

                    ToolTip = 'Specifies the value of the Entity Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Entity Key"; Rec."Entity Key")
                {

                    ToolTip = 'Specifies the value of the Entity Key field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

