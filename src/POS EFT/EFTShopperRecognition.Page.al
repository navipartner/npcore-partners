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

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Integration Type"; "Integration Type")
                {
                    ApplicationArea = All;
                }
                field("Shopper Reference"; "Shopper Reference")
                {
                    ApplicationArea = All;
                }
                field("Contract ID"; "Contract ID")
                {
                    ApplicationArea = All;
                }
                field("Contract Type"; "Contract Type")
                {
                    ApplicationArea = All;
                }
                field("Entity Type"; "Entity Type")
                {
                    ApplicationArea = All;
                }
                field("Entity Key"; "Entity Key")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

