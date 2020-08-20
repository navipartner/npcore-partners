table 6060155 "Event Attribute Col. Template"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.33/TJ  /20170529 CASE 277946 Added code for deletion and a check

    Caption = 'Event Attribute Col. Template';
    DataClassification = CustomerContent;
    LookupPageID = "Event Attribute Col. Templates";

    fields
    {
        field(1; Name; Code[20])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        EventAttrMgt: Codeunit "Event Attribute Management";
        EventAttrColValue: Record "Event Attribute Column Value";
    begin
        //-NPR5.33 [277946]
        EventAttrMgt.TemplateHasEntries(1, Name);
        EventAttrColValue.SetRange("Template Name", Name);
        EventAttrColValue.DeleteAll;
        //+NPR5.33 [277946]
    end;
}

