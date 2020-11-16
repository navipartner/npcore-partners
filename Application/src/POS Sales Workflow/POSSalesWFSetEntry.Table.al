table 6150732 "NPR POS Sales WF Set Entry"
{
    // NPR5.45/MHA /20180820  CASE 321266 Object created

    Caption = 'POS Sales Workflow Set Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Set Code"; Code[20])
        {
            Caption = 'Set Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Sales Workflow Set";
        }
        field(5; "Workflow Code"; Code[20])
        {
            Caption = 'Workflow Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Sales Workflow";
        }
        field(10; "Workflow Description"; Text[100])
        {
            CalcFormula = Lookup ("NPR POS Sales Workflow".Description WHERE(Code = FIELD("Workflow Code")));
            Caption = 'Workflow Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; "Workflow Steps"; Integer)
        {
            CalcFormula = Count ("NPR POS Sales Workflow Step" WHERE("Set Code" = FIELD("Set Code"),
                                                                 "Workflow Code" = FIELD("Workflow Code")));
            Caption = 'Workflow Steps';
            Description = 'NPR5.45';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Set Code", "Workflow Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        POSSalesWorkflowStep.SetRange("Set Code", "Set Code");
        POSSalesWorkflowStep.SetRange("Workflow Code", "Workflow Code");
        if POSSalesWorkflowStep.FindFirst then
            POSSalesWorkflowStep.DeleteAll;
    end;

    trigger OnRename()
    begin
        Error(Text000);
    end;

    var
        Text000: Label 'Rename not allowed';
}

