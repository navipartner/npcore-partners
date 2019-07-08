page 6059901 "Task Batch"
{
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Added setupnewbatch call + removed unused fields

    Caption = 'Task Batch';
    PageType = List;
    SourceTable = "Task Batch";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Journal Template Name";"Journal Template Name")
                {
                }
                field(Name;Name)
                {
                }
                field(Description;Description)
                {
                }
                field("Task Worker Group";"Task Worker Group")
                {
                }
                field("Common Companies";"Common Companies")
                {
                }
                field("Master Company";"Master Company")
                {
                }
                field("Mail From Address";"Mail From Address")
                {
                }
                field("Mail From Name";"Mail From Name")
                {
                }
                field("Template Type";"Template Type")
                {
                }
                field("Delete Log After";"Delete Log After")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-TQ1.29
        SetupNewBatch;
        //+TQ1.29
    end;
}

