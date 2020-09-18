page 6059900 "NPR Task Template"
{
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Added Action Templates. Removed unussed field

    Caption = 'Task Template';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Task Template";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Test Report ID"; "Test Report ID")
                {
                    ApplicationArea = All;
                }
                field("Page ID"; "Page ID")
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
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Test Report Name"; "Test Report Name")
                {
                    ApplicationArea = All;
                }
                field("Page Name"; "Page Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Te&mplate")
            {
                Caption = 'Te&mplate';
                Image = Template;
                action(Batches)
                {
                    Caption = 'Batches';
                    Image = Description;
                    RunObject = Page "NPR Task Batch";
                    RunPageLink = "Journal Template Name" = FIELD(Name);
                    ApplicationArea = All;
                }
            }
        }
    }
}

