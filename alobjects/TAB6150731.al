table 6150731 "POS Sales Workflow Set"
{
    // NPR5.45/MHA /20180820  CASE 321266 Object created

    Caption = 'POS Sales Workflow Set';
    DataClassification = CustomerContent;
    DrillDownPageID = "POS Sales Workflow Sets";
    LookupPageID = "POS Sales Workflow Sets";

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
        POSSalesWorkflowStep: Record "POS Sales Workflow Step";
        POSSalesWorkflowSetEntry: Record "POS Sales Workflow Set Entry";
    begin
        POSSalesWorkflowStep.SetRange("Set Code", Code);
        if POSSalesWorkflowStep.FindFirst then
            POSSalesWorkflowStep.DeleteAll;

        POSSalesWorkflowSetEntry.SetRange("Set Code", Code);
        if POSSalesWorkflowSetEntry.FindFirst then
            POSSalesWorkflowSetEntry.DeleteAll;
    end;
}

