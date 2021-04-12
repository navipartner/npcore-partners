table 6060154 "NPR Event Att. Row Templ."
{
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

    trigger OnDelete()
    var
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
        EventAttrRowValue: Record "NPR Event Attr. Row Value";
    begin
        EventAttrMgt.TemplateHasEntries(0, Name);
        EventAttrRowValue.SetRange("Template Name", Name);
        EventAttrRowValue.DeleteAll();
    end;
}

