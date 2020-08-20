table 6150726 "POS Action Sequence"
{
    // NPR5.53/VB  /20190917  CASE 362777 Support for workflow sequencing (configuring/registering "before" and "after" workflow sequences that execute before or after another workflow)

    Caption = 'POS Action Sequence';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Reference Type"; Option)
        {
            Caption = 'Reference Type';
            DataClassification = CustomerContent;
            Description = 'DO NOT TRANSLATE OptionCaption';
            OptionCaption = 'Before,After';
            OptionMembers = Before,After;
        }
        field(2; "Reference POS Action Code"; Code[20])
        {
            Caption = 'Reference POS Action Code';
            DataClassification = CustomerContent;
            TableRelation = "POS Action" WHERE("Workflow Engine Version" = FILTER(>= '2.0'));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                MakeSureActionIsAtLeast20("Reference POS Action Code");
            end;
        }
        field(3; "POS Action Code"; Code[20])
        {
            Caption = 'POS Action Code';
            DataClassification = CustomerContent;
            TableRelation = "POS Action" WHERE("Workflow Engine Version" = FILTER(>= '2.0'));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                MakeSureActionIsAtLeast20("POS Action Code");
            end;
        }
        field(4; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            Description = 'DO NOT TRANSLATE OptionCaption';
            Editable = false;
            OptionMembers = Manual,Discovery;
        }
    }

    keys
    {
        key(Key1; "Reference Type", "Reference POS Action Code", "POS Action Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        CheckAllSequences();
    end;

    trigger OnRename()
    begin
        CheckAllSequences();
    end;

    var
        Text001: Label 'Discovery was attempted on a manually configured action sequence: "Execute %1 %2 %3".\The same action sequence cannot be both manually configured and discovered. Remove the manual configuration and re-run discovery.';
        TempRec: Record "POS Action Sequence" temporary;
        Text002: Label 'Running action %1 %2 %3 would cause a circular action sequence.';
        Text003: Label 'Cannot run %1 %2 itself.';
        Text004: Label 'must be at minimum 2.0';
        TempActionForValidation: Record "POS Action" temporary;
        HasActionsForValidation: Boolean;

    procedure SetActionsForValidation(var TempAction: Record "POS Action" temporary)
    begin
        if TempAction.FindSet then
            repeat
                TempActionForValidation := TempAction;
                TempActionForValidation.Insert();
            until TempAction.Next = 0;
        HasActionsForValidation := true;
    end;

    local procedure MakeSureActionIsAtLeast20(ActionCode: Code[20])
    var
        POSAction: Record "POS Action";
    begin
        if HasActionsForValidation then begin
            TempActionForValidation.Get(ActionCode);
            POSAction := TempActionForValidation;
        end else
            POSAction.Get(ActionCode);

        if (POSAction."Workflow Engine Version" < '2.0') then
            POSAction.FieldError("Workflow Engine Version", Text004);
    end;

    procedure RunActionSequenceDiscovery()
    var
        Sequence: Record "POS Action Sequence";
        ParameterValue: Record "POS Parameter Value";
    begin
        TempRec.DeleteAll;
        Sequence.SetRange("Source Type", "Source Type"::Discovery);
        if Sequence.FindSet() then
            repeat
                TempRec := Sequence;
                TempRec.Insert();
            until Sequence.Next = 0;

        OnDiscoverActionSequence();

        if TempRec.FindSet() then
            repeat
                Sequence := TempRec;
                if Sequence.Find('=') then begin
                    ParameterValue.SetRange(ParameterValue."Table No.", DATABASE::"POS Action Sequence");
                    ParameterValue.SetRange("Record ID", RecordId);
                    ParameterValue.DeleteAll();
                    Sequence.Delete();
                end;
            until TempRec.Next = 0;

        CheckAllSequences();
    end;

    procedure DiscoverActionSequence(ReferenceType: Option Before,After; ReferenceActionCode: Code[20]; ActionCode: Code[20]; SequenceNo: Integer; DescriptionIn: Text)
    var
        PrevRec: Text;
    begin
        if ReferenceActionCode = ActionCode then
            Error(Text003, ReferenceActionCode, ReferenceType);

        if not Get(ReferenceType, ReferenceActionCode, ActionCode) then begin
            Init;
            "Reference Type" := ReferenceType;
            Validate("Reference POS Action Code", ReferenceActionCode);
            Validate("POS Action Code", ActionCode);
            "Source Type" := "Source Type"::Discovery;
            Insert();
        end;

        if "Source Type" = "Source Type"::Manual then
            Error(Text001, "POS Action Code", "Reference Type", "Reference POS Action Code");

        PrevRec := Format(Rec);

        "Sequence No." := SequenceNo;
        Description := Description;

        if PrevRec <> Format(Rec) then
            Modify();

        if TempRec.Get("Reference Type", "Reference POS Action Code", "POS Action Code") then
            TempRec.Delete();
    end;

    local procedure CheckAllSequences()
    var
        Sequence: Record "POS Action Sequence";
    begin
        if Sequence.FindSet() then
            repeat
                if not SimulateAction(Sequence."Reference POS Action Code") then
                    Error(Text002, Sequence."POS Action Code", Sequence."Reference Type", Sequence."Reference POS Action Code");
            until Sequence.Next = 0;
    end;

    local procedure SimulateAction(ReferenceActionCode: Code[20]): Boolean
    var
        TempToDo: Record "POS Action" temporary;
        TempDone: Record "POS Action" temporary;
    begin
        if not SimulateBeforeAction(TempToDo, ReferenceActionCode) then
            exit(false);

        if not SimulateAfterAction(TempToDo, ReferenceActionCode) then
            exit(false);

        exit(true);
    end;

    local procedure SimulateBeforeAction(var TempToDo: Record "POS Action" temporary; ReferenceActionCode: Code[20]): Boolean
    var
        Sequence: Record "POS Action Sequence";
        TempSequence: Record "POS Action Sequence" temporary;
    begin
        TempToDo.Code := ReferenceActionCode;
        if not TempToDo.Insert() then
            exit(false);

        Sequence.SetRange("Reference POS Action Code", ReferenceActionCode);
        Sequence.SetRange("Reference Type", "Reference Type"::Before);
        if Sequence.FindSet then
            repeat
                TempSequence := Sequence;
                TempSequence.Insert();
            until Sequence.Next = 0;
        if Rec."Reference POS Action Code" = ReferenceActionCode then begin
            TempSequence := Rec;
            if TempSequence.Insert() then;
        end;

        if TempSequence.FindSet() then
            repeat
                if not SimulateBeforeAction(TempToDo, TempSequence."POS Action Code") then
                    exit(false);

                if not SimulateAfterAction(TempToDo, TempSequence."POS Action Code") then
                    exit(false);
            until TempSequence.Next = 0;

        TempToDo.Code := ReferenceActionCode;
        TempToDo.Find('=');
        TempToDo.Delete();

        exit(true);
    end;

    local procedure SimulateAfterAction(var TempToDo: Record "POS Action" temporary; ReferenceActionCode: Code[20]): Boolean
    var
        Sequence: Record "POS Action Sequence";
        TempSequence: Record "POS Action Sequence" temporary;
    begin
        TempToDo.Code := ReferenceActionCode;
        if not TempToDo.Insert() then
            exit(false);

        Sequence.SetRange("Reference POS Action Code", ReferenceActionCode);
        Sequence.SetRange("Reference Type", "Reference Type"::After);
        if Sequence.FindSet then
            repeat
                TempSequence := Sequence;
                TempSequence.Insert();
            until Sequence.Next = 0;
        if Rec."Reference POS Action Code" = ReferenceActionCode then begin
            TempSequence := Rec;
            if TempSequence.Insert() then;
        end;

        if TempSequence.FindSet() then
            repeat
                if not SimulateBeforeAction(TempToDo, TempSequence."POS Action Code") then
                    exit(false);

                if not SimulateAfterAction(TempToDo, TempSequence."POS Action Code") then
                    exit(false);
            until TempSequence.Next = 0;

        TempToDo.Code := ReferenceActionCode;
        TempToDo.Find('=');
        TempToDo.Delete();

        exit(true);
    end;

    [BusinessEvent(TRUE)]
    local procedure OnDiscoverActionSequence()
    begin
    end;
}

