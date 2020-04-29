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
                field("Batch Posting";"Batch Posting")
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

