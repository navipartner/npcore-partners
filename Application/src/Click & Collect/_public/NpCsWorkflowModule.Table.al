﻿table 6151197 "NPR NpCs Workflow Module"
{
    Access = Public;
    Caption = 'Collect Workflow Module';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpCs Workflow Modules";
    LookupPageID = "NPR NpCs Workflow Modules";

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            OptionCaption = 'Send Order,Order Status,Post Processing';
            OptionMembers = "Send Order","Order Status","Post Processing";
        }
        field(5; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; "Event Codeunit ID"; Integer)
        {
            Caption = 'Event Codeunit ID';
            DataClassification = CustomerContent;
        }
        field(55; "Event Codeunit Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Event Codeunit ID")));
            Caption = 'Event Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; Type, "Code")
        {
        }
    }
}

