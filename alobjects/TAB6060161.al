table 6060161 "Event Exch. Int. Temp. Entry"
{
    // NPR5.34/TJ  /20170728 CASE 277938 New object

    Caption = 'Event Exch. Int. Temp. Entry';

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = "Event Exch. Int. Template";

            trigger OnValidate()
            begin
                EventExchIntTemplate.Get(Code);
                Description := EventExchIntTemplate.Description;
            end;
        }
        field(2;"Source Record ID";RecordID)
        {
            Caption = 'Source Record ID';
        }
        field(10;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(20;Active;Boolean)
        {
            Caption = 'Active';
        }
    }

    keys
    {
        key(Key1;"Code","Source Record ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Active := true;
    end;

    var
        EventExchIntTemplate: Record "Event Exch. Int. Template";
}

