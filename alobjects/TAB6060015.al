table 6060015 "GIM - Mail Header"
{
    Caption = 'GIM - Mail Header';
    LookupPageID = "GIM - Mail List";

    fields
    {
        field(1;"Sender ID";Code[20])
        {
            Caption = 'Sender ID';
            TableRelation = "GIM - Document Type"."Sender ID";
        }
        field(2;"Process Code";Code[10])
        {
            Caption = 'Process Code';
            TableRelation = "GIM - Process Flow".Code;
        }
        field(10;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(20;"To";Text[250])
        {
            Caption = 'To';
        }
        field(30;Cc;Text[250])
        {
            Caption = 'Cc';
        }
        field(40;Subject;Text[30])
        {
            Caption = 'Subject';
        }
        field(50;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = ' ,Ready';
            OptionMembers = " ",Ready;
        }
    }

    keys
    {
        key(Key1;"Sender ID","Process Code")
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

    trigger OnModify()
    begin
        TestStatusOpen();
    end;

    procedure TestStatusOpen()
    begin
        TestField(Status,Status::" ");
    end;

    procedure StatusChanger(NewStatus: Integer)
    begin
        Status := NewStatus;
        Modify;
    end;
}

