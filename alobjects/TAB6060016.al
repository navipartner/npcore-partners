table 6060016 "GIM - Mail Line"
{
    Caption = 'GIM - Mail Line';

    fields
    {
        field(1;"Sender ID";Code[20])
        {
            Caption = 'Sender ID';
        }
        field(2;"Process Code";Code[10])
        {
            Caption = 'Process Code';
        }
        field(3;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Line Type";Option)
        {
            Caption = 'Line Type';
            OptionCaption = 'Text,Empty Line,Separator,Details';
            OptionMembers = Text,"Empty Line",Separator,Details;

            trigger OnValidate()
            begin
                if ("Line Type" <> xRec."Line Type") and ("Line Type" <> "Line Type"::Text) then
                  Description := '';
            end;
        }
        field(20;Description;Text[250])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Sender ID","Process Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestStatusOpen();
    end;

    trigger OnInsert()
    begin
        TestStatusOpen();
    end;

    trigger OnModify()
    begin
        TestStatusOpen();
    end;

    var
        MailHeader: Record "GIM - Mail Header";

    procedure TestStatusOpen()
    begin
        MailHeader.Get("Sender ID","Process Code");
        MailHeader.TestStatusOpen();
    end;
}

