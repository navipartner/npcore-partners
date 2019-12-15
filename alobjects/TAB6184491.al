table 6184491 "Pepper Instance"
{
    Caption = 'Pepper Instance';
    DataCaptionFields = ID,Description;
    DrillDownPageID = "Pepper Instances";
    LookupPageID = "Pepper Instances";

    fields
    {
        field(10;ID;Integer)
        {
            Caption = 'ID';
        }
        field(20;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(50;"Configuration Code";Code[10])
        {
            Caption = 'Configuration Code';
            TableRelation = "Pepper Configuration";
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PepperTerminal: Record "Pepper Terminal";
        TextTerminalFound: Label 'There is at least one Pepper Terminal linked to this Instance. Remove the link on the Pepper Terminal Card before deleteing this record.';
    begin
        PepperTerminal.SetRange("Instance ID",ID);
        if not PepperTerminal.IsEmpty then
          Error(TextTerminalFound);
    end;
}

