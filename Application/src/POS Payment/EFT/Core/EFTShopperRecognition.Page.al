page 6184505 "NPR EFT Shopper Recognition"
{
    Extensible = False;
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

                    ToolTip = 'Specifies the integration type.';
                    ApplicationArea = NPRRetail;
                }
                field("Shopper Reference"; Rec."Shopper Reference")
                {

                    ToolTip = 'Specifies the shopper reference.';
                    ApplicationArea = NPRRetail;
                }
                field("Contract ID"; Rec."Contract ID")
                {

                    ToolTip = 'Specifies the contract ID.';
                    ApplicationArea = NPRRetail;
                }
                field("Contract Type"; Rec."Contract Type")
                {

                    ToolTip = 'Specifies the contract type.';
                    ApplicationArea = NPRRetail;
                }
                field("Entity Type"; Rec."Entity Type")
                {

                    ToolTip = 'Specifies the entity type.';
                    ApplicationArea = NPRRetail;
                }
                field("Entity Key"; Rec."Entity Key")
                {

                    ToolTip = 'Specifies the entity key.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

