page 6151152 "Customers to Anonymize List"
{
    // NPR5.53/JAKUBV/20200121  CASE 358656-01 Transport NPR5.53 - 21 January 2020

    Caption = 'Customers to Anonymize List';
    PageType = List;
    SourceTable = "Customers to Anonymize";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No"; "Customer No")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; "Customer Name")
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

