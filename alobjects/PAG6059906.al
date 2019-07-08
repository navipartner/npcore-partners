page 6059906 "Task Worker Group"
{
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue

    Caption = 'Task Worker Group';
    PageType = List;
    SourceTable = "Task Worker Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Language ID";"Language ID")
                {
                }
                field("Abbreviated Name";"Abbreviated Name")
                {
                }
                field("Min Interval Between Check";"Min Interval Between Check")
                {
                }
                field("Max Interval Between Check";"Max Interval Between Check")
                {
                }
                field(Default;Default)
                {
                }
            }
        }
    }

    actions
    {
    }
}

