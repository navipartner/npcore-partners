table 6014512 "Custom Object Selection"
{
    // NPR4.02/TR/20150401  CASE 207094 Table created in order to do custom object selection.

    Caption = 'Brugerdefineret objektvalg';

    fields
    {
        field(1;"Group Code";Code[20])
        {
            Caption = 'Group Code';
        }
        field(2;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = 'Title,Table,Form,Report,Dataport,Codeunit,XMLPort,,Page';
            OptionMembers = Title,"Table",Form,"Report",Dataport,"Codeunit","XMLPort",,"Page";
        }
        field(3;"Object ID";Integer)
        {
            Caption = 'Object ID';
            TableRelation = IF ("Object Type"=FILTER(<>Title)) AllObj."Object ID" WHERE ("Object Type"=FIELD("Object Type"));

            trigger OnValidate()
            begin
                if "Object ID" <> 0 then begin
                  AllObj.Get("Object Type","Object ID");
                  Description := AllObj."Object Name";
                end;
            end;
        }
        field(4;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(5;Level;Integer)
        {
            Caption = 'Level';
        }
        field(6;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
    }

    keys
    {
        key(Key1;"Object Type","Object ID","Group Code","Entry No.")
        {
        }
        key(Key2;"Entry No.")
        {
            Enabled = false;
        }
    }

    fieldgroups
    {
    }

    var
        ObjectTypeOpt: Option All,"Table",Form,"Report",Dataport,"Codeunit","XMLPort","Menu Suite","Page";
        AllObj: Record AllObj;
}

