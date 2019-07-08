table 6151197 "NpCs Workflow Module"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Workflow Module';
    DrillDownPageID = "NpCs Workflow Modules";
    LookupPageID = "NpCs Workflow Modules";

    fields
    {
        field(1;Type;Option)
        {
            Caption = 'Type';
            NotBlank = true;
            OptionCaption = 'Send Order,Order Status,Post Processing';
            OptionMembers = "Send Order","Order Status","Post Processing";
        }
        field(5;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(50;"Event Codeunit ID";Integer)
        {
            Caption = 'Event Codeunit ID';
        }
        field(55;"Event Codeunit Name";Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Codeunit),
                                                             "Object ID"=FIELD("Event Codeunit ID")));
            Caption = 'Event Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;Type,"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

