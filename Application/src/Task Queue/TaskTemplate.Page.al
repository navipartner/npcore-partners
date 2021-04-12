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
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Test Report ID"; Rec."Test Report ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Test Report ID field';
                }
                field("Page ID"; Rec."Page ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Form ID field';
                }
                field("Mail From Address"; Rec."Mail From Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mail From Address field';
                }
                field("Mail From Name"; Rec."Mail From Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mail From Name field';
                }
                field("Task Worker Group"; Rec."Task Worker Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Worker Group field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Test Report Name"; Rec."Test Report Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Test Report Name field';
                }
                field("Page Name"; Rec."Page Name")
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

