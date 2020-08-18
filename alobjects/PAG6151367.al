page 6151367 "CS Transfer Handling Batch"
{
    // NPR5.55/JAKUBV/20200807  CASE 379709-01 Transport NPR5.55 - 31 July 2020

    Caption = 'CS Transfer Handling Batch';
    DelayedInsert = false;
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "CS Transfer Handling Rfid";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Device Id";"Device Id")
                {
                }
                field(Tags;Tags)
                {
                }
                field(Handled;Handled)
                {
                }
                field(Created;Created)
                {
                }
                field("Created By";"Created By")
                {
                }
                field("Posting Started";"Posting Started")
                {
                }
                field("Posting Ended";"Posting Ended")
                {
                }
                field("Area";Area)
                {
                }
            }
        }
    }

    actions
    {
    }
}

