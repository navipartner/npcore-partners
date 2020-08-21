page 6151397 "CS Stock-Take Batch List"
{
    // NPR5.54/JAKUBV/20200408  CASE 389224 Transport NPR5.54 - 8 April 2020

    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "CS Stock-Take Handling Rfid";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Device Id"; "Device Id")
                {
                    ApplicationArea = All;
                }
                field(Tags; Tags)
                {
                    ApplicationArea = All;
                }
                field(Handled; Handled)
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                }
                field("Batch Posting"; "Batch Posting")
                {
                    ApplicationArea = All;
                }
                field("Posting Started"; "Posting Started")
                {
                    ApplicationArea = All;
                }
                field("Posting Ended"; "Posting Ended")
                {
                    ApplicationArea = All;
                }
                field("Area"; Area)
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

