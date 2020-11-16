table 6060154 "NPR Event Att. Row Templ."
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.33/TJ  /20170529 CASE 277946 Added code for deletion and a check

    Caption = 'Event Attribute Row Template';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Event Attr. Row Templ.";

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
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
        EventAttrRowValue: Record "NPR Event Attr. Row Value";
    begin
        //-NPR5.33 [277946]
        EventAttrMgt.TemplateHasEntries(0, Name);
        EventAttrRowValue.SetRange("Template Name", Name);
        EventAttrRowValue.DeleteAll;
        //+NPR5.33 [277946]
    end;
}

