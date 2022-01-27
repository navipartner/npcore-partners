table 6060157 "NPR Event Attr. Column Value"
{
    Access = Internal;
    Caption = 'Event Attribute Column Value';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Name"; Code[20])
        {
            Caption = 'Template Name';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Text,Decimal';
            OptionMembers = Text,Decimal;

            trigger OnValidate()
            begin
                if Type <> xRec.Type then
                    EventAttrMgt.TemplateHasEntries(1, "Template Name");
            end;
        }
        field(30; "Include in Formula"; Boolean)
        {
            Caption = 'Include in Formula';
            DataClassification = CustomerContent;
        }
        field(40; Promote; Boolean)
        {
            Caption = 'Promote';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Template Name", "Line No.")
        {
        }
    }

    trigger OnDelete()
    begin
        EventAttrMgt.TemplateHasEntries(1, "Template Name");
    end;

    var
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
}

