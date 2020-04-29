page 6184505 "EFT Shopper Recognition"
{
    // NPR5.49/MMV /20190410 CASE 347476 Created object

    Caption = 'EFT Shopper Recognition';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "EFT Shopper Recognition";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Integration Type";"Integration Type")
                {
                }
                field("Shopper Reference";"Shopper Reference")
                {
                }
                field("Contract ID";"Contract ID")
                {
                }
                field("Contract Type";"Contract Type")
                {
                }
                field("Entity Type";"Entity Type")
                {
                }
                field("Entity Key";"Entity Key")
                {
                }
            }
        }
    }

    actions
    {
    }
}

