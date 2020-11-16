page 6059901 "NPR Task Batch"
{
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Added setupnewbatch call + removed unused fields

    Caption = 'Task Batch';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Task Batch";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Journal Template Name"; "Journal Template Name")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                }
                field("Common Companies"; "Common Companies")
                {
                    ApplicationArea = All;
                }
                field("Master Company"; "Master Company")
                {
                    ApplicationArea = All;
                }
                field("Mail From Address"; "Mail From Address")
                {
                    ApplicationArea = All;
                }
                field("Mail From Name"; "Mail From Name")
                {
                    ApplicationArea = All;
                }
                field("Template Type"; "Template Type")
                {
                    ApplicationArea = All;
                }
                field("Delete Log After"; "Delete Log After")
                {
                    ApplicationArea = All;
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

