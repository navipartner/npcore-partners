table 6014536 "Retail List"
{
    Caption = 'Retail List';
    LookupPageID = "Retail List";

    fields
    {
        field(1;Number;Integer)
        {
            Caption = 'Number';
        }
        field(2;Choice;Text[246])
        {
            Caption = 'Choice';
        }
        field(3;Chosen;Boolean)
        {
            Caption = 'Chosen';
        }
        field(10;Value;Text[250])
        {
            Caption = 'Value';
        }
    }

    keys
    {
        key(Key1;Number)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        nummerserie: Code[20];
    begin
    end;

    var
        Nrseriestyring: Codeunit NoSeriesManagement;
}

