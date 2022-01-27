table 6150731 "NPR POS Sales Workflow Set"
{
    Access = Internal;

    Caption = 'POS Sales Workflow Set';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Scenarios Sets";
    LookupPageID = "NPR POS Scenarios Sets";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSSalesWorkflowSetEntry: Record "NPR POS Sales WF Set Entry";
    begin
        POSSalesWorkflowStep.SetRange("Set Code", Code);
        if POSSalesWorkflowStep.FindFirst() then
            POSSalesWorkflowStep.DeleteAll();

        POSSalesWorkflowSetEntry.SetRange("Set Code", Code);
        if POSSalesWorkflowSetEntry.FindFirst() then
            POSSalesWorkflowSetEntry.DeleteAll();
    end;
}

