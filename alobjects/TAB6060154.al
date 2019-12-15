table 6060154 "Event Attribute Row Template"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.33/TJ  /20170529 CASE 277946 Added code for deletion and a check

    Caption = 'Event Attribute Row Template';
    LookupPageID = "Event Attribute Row Templates";

    fields
    {
        field(1;Name;Code[20])
        {
            Caption = 'Name';
        }
        field(10;Description;Text[30])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        EventAttrMgt: Codeunit "Event Attribute Management";
        EventAttrRowValue: Record "Event Attribute Row Value";
    begin
        //-NPR5.33 [277946]
        EventAttrMgt.TemplateHasEntries(0,Name);
        EventAttrRowValue.SetRange("Template Name",Name);
        EventAttrRowValue.DeleteAll;
        //+NPR5.33 [277946]
    end;
}

