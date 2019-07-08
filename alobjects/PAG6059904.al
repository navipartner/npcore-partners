page 6059904 "Task Log (Task)"
{
    // TQ1.17/JDH/20141015 CASE 179044 Page made non editable
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Changed sorting order

    Caption = 'Task Log';
    Editable = false;
    PageType = List;
    SourceTable = "Task Log (Task)";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Journal Template Name";"Journal Template Name")
                {
                }
                field("Journal Batch Name";"Journal Batch Name")
                {
                }
                field("Line No.";"Line No.")
                {
                }
                field("Entry Type";"Entry Type")
                {
                }
                field("Starting Time";"Starting Time")
                {
                }
                field("Expected Ending Time";"Expected Ending Time")
                {
                }
                field("Ending Time";"Ending Time")
                {
                }
                field("Task Duration";"Task Duration")
                {
                }
                field(Status;Status)
                {
                }
                field("Last Error Message";"Last Error Message")
                {
                }
                field("User ID";"User ID")
                {
                }
                field("Server Instance ID";"Server Instance ID")
                {
                }
                field("Session ID";"Session ID")
                {
                }
                field("Task Worker Group";"Task Worker Group")
                {
                }
                field("Object Type";"Object Type")
                {
                }
                field("Object No.";"Object No.")
                {
                }
                field("No. of Output Log Entries";"No. of Output Log Entries")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if FindFirst then;
    end;
}

