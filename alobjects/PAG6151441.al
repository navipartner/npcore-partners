page 6151441 "Magento Contact Pmt. Methods"
{
    // MAG1.05/20150223  CASE 206395 Object created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Contact Payment Methods';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Magento Contact Pmt. Method";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Payment Method Code"; "External Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Payment Method Code"; "Payment Method Code")
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

