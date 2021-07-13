page 6059900 "NPR Task Template"
{
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Added Action Templates. Removed unussed field

    Caption = 'Task Template';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Task Template";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Test Report ID"; Rec."Test Report ID")
                {

                    ToolTip = 'Specifies the value of the Test Report ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Page ID"; Rec."Page ID")
                {

                    ToolTip = 'Specifies the value of the Form ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Mail From Address"; Rec."Mail From Address")
                {

                    ToolTip = 'Specifies the value of the Mail From Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Mail From Name"; Rec."Mail From Name")
                {

                    ToolTip = 'Specifies the value of the Mail From Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Worker Group"; Rec."Task Worker Group")
                {

                    ToolTip = 'Specifies the value of the Task Worker Group field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Test Report Name"; Rec."Test Report Name")
                {

                    ToolTip = 'Specifies the value of the Test Report Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Page Name"; Rec."Page Name")
                {

                    ToolTip = 'Specifies the value of the Form Name field';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Batches action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

