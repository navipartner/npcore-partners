table 6060155 "NPR Event Attr. Col. Template"
{
    Access = Internal;
    Caption = 'Event Attribute Col. Template';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Event Attr. Col. Templates";

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
        EventAttrColValue: Record "NPR Event Attr. Column Value";
    begin
        EventAttrMgt.TemplateHasEntries(1, Name);
        EventAttrColValue.SetRange("Template Name", Name);
        EventAttrColValue.DeleteAll();
    end;
}

