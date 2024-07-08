table 6060162 "NPR Event Attribute"
{
    Access = Internal;
    Caption = 'Event Attribute';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            DataClassification = CustomerContent;
        }
        field(2; "Template Name"; Code[20])
        {
            Caption = 'Template Name';
            DataClassification = CustomerContent;
            TableRelation = "NPR Event Attribute Template";
        }
        field(10; Promote; Boolean)
        {
            Caption = 'Promote';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Job No.", "Template Name")
        {
        }
    }

    trigger OnDelete()
    var
        EventAttributeEntry: Record "NPR Event Attribute Entry";
        ConfirmAttributeDelete: Label 'This will delete all attribute values allready entered for template %1. Do you want to continue?';
    begin
        EventAttributeEntry.SetRange("Template Name", "Template Name");
        EventAttributeEntry.SetRange("Job No.", "Job No.");
        if not EventAttributeEntry.IsEmpty then begin
            if not Confirm(StrSubstNo(ConfirmAttributeDelete, "Template Name")) then
                Error('');
            EventAttributeEntry.DeleteAll();
        end;
    end;

    trigger OnInsert()
    var
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
        ReturnMsg: Text;
    begin
        EventAttrMgt.CopyAttributes("Template Name", '', "Job No.", ReturnMsg);
    end;
}

