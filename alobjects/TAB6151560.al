table 6151560 "NpXml Template History"
{
    // NC1.21/TTH/20151020 CASE 224528 Adding versioning and possibility to lock the modified versions. New table for template history.
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NpXml Template History';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NpXml Template";
        }
        field(3; "Template Version No."; Code[20])
        {
            Caption = 'Template Version No.';
            DataClassification = CustomerContent;
        }
        field(10; "Changed by"; Code[50])
        {
            Caption = 'Changed by';
            DataClassification = CustomerContent;
        }
        field(20; "Change at"; DateTime)
        {
            Caption = 'Change at';
            DataClassification = CustomerContent;
        }
        field(30; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(40; "Version Description"; Text[250])
        {
            Caption = 'Version Description';
            DataClassification = CustomerContent;
        }
        field(50; "Event Type"; Option)
        {
            Caption = 'Event Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Archivation,Modification,Restore';
            OptionMembers = Archivation,Modification,Restore;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Template Code", "Template Version No.", "Change at")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text000: Label 'Template Archived';
        Text001: Label 'Template Version %1 Restored';
        Text002: Label 'Template Changed';

    procedure InsertHistory(XmlTemplate: Code[20]; TemplateVersionNo: Code[20]; EventType: Option New,Modification,Restore; VersionDescription: Text[250])
    var
        NpXmlAttribute: Record "NpXml Attribute";
        NpXmlElement: Record "NpXml Element";
        NpXmlFilter: Record "NpXml Filter";
        NpXmlTemplate: Record "NpXml Template";
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
        NpXmlTemplateArchive: Record "NpXml Template Archive";
        TemplateHistory: Record "NpXml Template History";
        TemplateHistory2: Record "NpXml Template History";
        EntryNo: Integer;
        FieldRef: FieldRef;
    begin
        //-NC1.21
        TemplateHistory2.SetRange("Template Code", XmlTemplate);
        if TemplateHistory2.FindLast and (TemplateHistory2."Changed by" = UserId) and (TemplateHistory2."Event Type" = EventType) and (TemplateVersionNo = TemplateHistory2."Template Version No.") then
            exit;

        TemplateHistory.Init;
        TemplateHistory."Entry No." := 0;
        TemplateHistory."Template Code" := XmlTemplate;
        TemplateHistory."Template Version No." := TemplateVersionNo;
        case EventType of
            EventType::New:
                TemplateHistory.Description := Text000;
            EventType::Restore:
                TemplateHistory.Description := StrSubstNo(Text001, TemplateVersionNo);
            EventType::Modification:
                TemplateHistory.Description := Text002;
        end;
        TemplateHistory."Version Description" := VersionDescription;
        TemplateHistory."Event Type" := EventType;
        TemplateHistory."Changed by" := UserId;
        TemplateHistory."Change at" := CreateDateTime(Today, Time);
        TemplateHistory.Insert;
        //+NC1.21
    end;
}

