page 6151441 "NPR Magento Cont.Pmt.Methods"
{
    // MAG1.05/20150223  CASE 206395 Object created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Contact Payment Methods';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Magento Contact Pmt.Meth.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Payment Method Code"; "External Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Payment Method Code field';
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
            }
        }
    }

    actions
    {
    }
}

