page 6151152 "NPR Customers to Anon. List"
{
    // NPR5.53/JAKUBV/20200121  CASE 358656-01 Transport NPR5.53 - 21 January 2020

    Caption = 'Customers to Anonymize List';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Customers to Anonymize";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No"; Rec."Customer No")
                {

                    ToolTip = 'Specifies the value of the Customer No field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Name"; Rec."Customer Name")
                {

                    ToolTip = 'Specifies the value of the Customer Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

