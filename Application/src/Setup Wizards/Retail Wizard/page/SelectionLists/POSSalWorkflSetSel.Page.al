page 6059777 "NPR POS Sal. Workfl. Set. Sel."
{
    Caption = 'POS Sales Workflow Sets';
    PageType = List;
    SourceTable = "NPR POS Sales Workflow Set";
    SourceTableTemporary = true;
    DelayedInsert = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    procedure SetRec(var TempPOSSalesWorkflowSet: Record "NPR POS Sales Workflow Set")
    begin
        if TempPOSSalesWorkflowSet.FindSet() then
            repeat
                Rec.Copy(TempPOSSalesWorkflowSet);
                Rec.Insert();
            until TempPOSSalesWorkflowSet.Next() = 0;

        if Rec.FindSet() then;
    end;
}