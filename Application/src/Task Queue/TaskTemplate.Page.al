page 6059900 "NPR Task Template"
{
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Added Action Templates. Removed unussed field

    Caption = 'Task Template';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Test Report ID"; "Test Report ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Test Report ID field';
                }
                field("Page ID"; "Page ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Form ID field';
                }
                field("Mail From Address"; "Mail From Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mail From Address field';
                }
                field("Mail From Name"; "Mail From Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mail From Name field';
                }
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Worker Group field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Test Report Name"; "Test Report Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Test Report Name field';
                }
                field("Page Name"; "Page Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Form Name field';
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
                    ToolTip = 'Executes the Batches action';
                }
            }
        }
    }
}

