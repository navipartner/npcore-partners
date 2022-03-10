﻿page 6059777 "NPR POS Sal. Workfl. Set. Sel."
{
    Extensible = False;
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure SetRec(var TempPOSSalesWorkflowSet: Record "NPR POS Sales Workflow Set")
    begin
        if TempPOSSalesWorkflowSet.FindSet() then
            repeat
                Rec.Copy(TempPOSSalesWorkflowSet);
                Rec.Insert();
            until TempPOSSalesWorkflowSet.Next() = 0;

        if Rec.FindSet() then;
    end;
}
