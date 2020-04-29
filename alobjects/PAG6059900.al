page 6059900 "Task Template"
{
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Added Action Templates. Removed unussed field

    Caption = 'Task Template';
    PageType = List;
    SourceTable = "Task Template";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                }
                field(Description;Description)
                {
                }
                field("Test Report ID";"Test Report ID")
                {
                }
                field("Page ID";"Page ID")
                {
                }
                field("Mail From Address";"Mail From Address")
                {
                }
                field("Mail From Name";"Mail From Name")
                {
                }
                field("Task Worker Group";"Task Worker Group")
                {
                }
                field(Type;Type)
                {
                }
                field("Test Report Name";"Test Report Name")
                {
                }
                field("Page Name";"Page Name")
                {
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
                    RunObject = Page "Task Batch";
                    RunPageLink = "Journal Template Name"=FIELD(Name);
                }
            }
        }
    }
}

