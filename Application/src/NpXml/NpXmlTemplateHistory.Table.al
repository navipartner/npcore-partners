table 6151560 "NPR NpXml Template History"
{
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
            TableRelation = "NPR NpXml Template";
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

    var
        Text000: Label 'Template Archived';
        Text001: Label 'Template Version %1 Restored';
        Text002: Label 'Template Changed';

    procedure InsertHistory(XmlTemplate: Code[20]; TemplateVersionNo: Code[20]; EventType: Option New,Modification,Restore; VersionDescription: Text[250])
    var
        TemplateHistory: Record "NPR NpXml Template History";
        TemplateHistory2: Record "NPR NpXml Template History";
    begin
        TemplateHistory2.SetRange("Template Code", XmlTemplate);
        if TemplateHistory2.FindLast() and (TemplateHistory2."Changed by" = UserId) and (TemplateHistory2."Event Type" = EventType) and (TemplateVersionNo = TemplateHistory2."Template Version No.") then
            exit;

        TemplateHistory.Init();
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
        TemplateHistory.Insert();
    end;
}

