page 6151393 "CS Store Users"
{
    // NPR5.51/CLVA  /20190813  CASE 365659 Object created - NP Capture Service
    // NPR5.53/CLVA  /20191204  CASE 375919 Added field "Adjust Inventory"

    Caption = 'CS Store Users';
    PageType = List;
    SourceTable = "CS Store Users";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("POS Store"; "POS Store")
                {
                    ApplicationArea = All;
                }
                field(Supervisor; Supervisor)
                {
                    ApplicationArea = All;
                }
                field("Adjust Inventory"; "Adjust Inventory")
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

