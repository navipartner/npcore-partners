page 6059901 "NPR Task Batch"
{
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Added setupnewbatch call + removed unused fields

    Caption = 'Task Batch';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Task Batch";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Journal Template Name"; Rec."Journal Template Name")
                {

                    ToolTip = 'Specifies the value of the Journal Template Name field';
                    ApplicationArea = NPRRetail;
                }
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
                field("Task Worker Group"; Rec."Task Worker Group")
                {

                    ToolTip = 'Specifies the value of the Task Worker Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Common Companies"; Rec."Common Companies")
                {

                    ToolTip = 'Specifies the value of the Common Companies field';
                    ApplicationArea = NPRRetail;
                }
                field("Master Company"; Rec."Master Company")
                {

                    ToolTip = 'Specifies the value of the Master Company field';
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
                field("Template Type"; Rec."Template Type")
                {

                    ToolTip = 'Specifies the value of the Template Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Log After"; Rec."Delete Log After")
                {

                    ToolTip = 'Specifies the value of the Delete Log After field';
                    ApplicationArea = NPRRetail;
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

