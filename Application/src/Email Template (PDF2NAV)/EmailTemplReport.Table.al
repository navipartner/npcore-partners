﻿table 6014461 "NPR E-mail Templ. Report"
{
    Access = Internal;
    Caption = 'Report Selections - E-mail';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "E-mail Template Code"; Code[20])
        {
            Caption = 'E-mail Template Code';
            TableRelation = "NPR E-mail Template Header";
            DataClassification = CustomerContent;
        }
        field(2; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcFields("Report Name");
            end;
        }
        field(40; Filename; Text[250])
        {
            Caption = 'Filename';
            DataClassification = CustomerContent;
        }
        field(100; "Report Name"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Report),
                                                                           "Object ID" = field("Report ID")));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "E-mail Template Code", "Report ID")
        {
        }
    }

    trigger OnInsert()
    begin
        TestField(Filename);
    end;

    trigger OnModify()
    begin
        TestField(Filename);
    end;

}

