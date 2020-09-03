table 6060161 "NPR Event Exch.Int.Temp.Entry"
{
    // NPR5.34/TJ  /20170728 CASE 277938 New object

    Caption = 'Event Exch. Int. Temp. Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Event Exch. Int. Template";

            trigger OnValidate()
            begin
                EventExchIntTemplate.Get(Code);
                Description := EventExchIntTemplate.Description;
            end;
        }
        field(2; "Source Record ID"; RecordID)
        {
            Caption = 'Source Record ID';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code", "Source Record ID")
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
        EventExchIntTemplate: Record "NPR Event Exch. Int. Template";
}

