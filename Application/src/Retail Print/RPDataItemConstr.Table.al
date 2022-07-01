﻿table 6014563 "NPR RP Data Item Constr."
{
    Access = Internal;
    Caption = 'Data Item Constraint';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Data Item Code"; Code[20])
        {
            Caption = 'Data Item Code';
            TableRelation = "NPR RP Data Items".Code;
            DataClassification = CustomerContent;
        }
        field(2; "Data Item Line No."; Integer)
        {
            Caption = 'Data Item Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Constraint Type"; Option)
        {
            Caption = 'Constraint Type';
            OptionCaption = 'Is Empty,Is Not Empty';
            OptionMembers = IsEmpty,IsNotEmpty;
            DataClassification = CustomerContent;
        }
        field(5; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(6; "Table Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Data Item Code", "Data Item Line No.", "Line No.")
        {
        }
        key(Key2; "Data Item Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
    begin
        ModifiedRec();

        DataItemConstraintLinks.SetRange("Data Item Code", "Data Item Code");
        DataItemConstraintLinks.SetRange("Constraint Line No.", "Line No.");
        DataItemConstraintLinks.DeleteAll();
    end;

    trigger OnInsert()
    begin
        ModifiedRec();
        SetLineNo();
        TestField("Table ID");
    end;

    trigger OnModify()
    begin
        ModifiedRec();
    end;

    trigger OnRename()
    begin
        ModifiedRec();
    end;

    local procedure ModifiedRec()
    var
        RPTemplateHeder: Record "NPR RP Template Header";
    begin
        if IsTemporary then
            exit;
        if RPTemplateHeder.Get("Data Item Code") then
            RPTemplateHeder.Modify(true);
    end;

    local procedure SetLineNo()
    var
        DataItemConstraint: Record "NPR RP Data Item Constr.";
    begin
        DataItemConstraint.SetCurrentKey("Data Item Code", "Line No.");
        DataItemConstraint.SetRange("Data Item Code", "Data Item Code");
        if DataItemConstraint.FindLast() then;
        "Line No." := DataItemConstraint."Line No." + 10000;
    end;
}

