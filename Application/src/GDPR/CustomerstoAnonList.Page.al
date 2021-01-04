page 6151152 "NPR Customers to Anon. List"
{
    // NPR5.53/JAKUBV/20200121  CASE 358656-01 Transport NPR5.53 - 21 January 2020

    Caption = 'Customers to Anonymize List';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Customers to Anonymize";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No"; "Customer No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No field';
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Name field';
                }
            }
        }
    }

    actions
    {
    }
}

