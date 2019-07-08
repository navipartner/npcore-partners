page 6151382 "CS Stock-Take Rfid List"
{
    // NPR5.50/JAKUBV/20190603  CASE 344466 Transport NPR5.50 - 3 June 2019

    Caption = 'CS Stock-Take Rfid List';
    CardPageID = "CS Stock-Take Rfid Card";
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
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
                field(Id;Id)
                {
                }
                field("Batch Id";"Batch Id")
                {
                }
                field("Request Function";"Request Function")
                {
                }
                field("Batch No.";"Batch No.")
                {
                }
                field("Device Id";"Device Id")
                {
                }
                field("Stock-Take Config Code";"Stock-Take Config Code")
                {
                }
                field("Worksheet Name";"Worksheet Name")
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
                field("Posting Error";"Posting Error")
                {
                }
                field("Posting Error Detail";"Posting Error Detail")
                {
                }
            }
        }
    }

    actions
    {
    }
}

