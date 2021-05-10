page 6059901 "NPR Task Batch"
{
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Added setupnewbatch call + removed unused fields

    Caption = 'Task Batch';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Task Batch";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Template Name field';
                }
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
                field("Task Worker Group"; Rec."Task Worker Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Worker Group field';
                }
                field("Common Companies"; Rec."Common Companies")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Common Companies field';
                }
                field("Master Company"; Rec."Master Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Master Company field';
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
                field("Template Type"; Rec."Template Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template Type field';
                }
                field("Delete Log After"; Rec."Delete Log After")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Log After field';
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
        Rec.SetupNewBatch();
        //+TQ1.29
    end;
}

