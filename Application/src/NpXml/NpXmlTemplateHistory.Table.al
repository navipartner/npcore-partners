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
            DataClassification = EndUserIdentifiableInformation;
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
        NpXm1TemplateHistory: Record "NPR NpXml Template History";
        NpXm1TemplateHistory2: Record "NPR NpXml Template History";
    begin
        NpXm1TemplateHistory2.SetRange("Template Code", XmlTemplate);
        if NpXm1TemplateHistory2.FindLast() and (NpXm1TemplateHistory2."Changed by" = UserId) and (NpXm1TemplateHistory2."Event Type" = EventType) and (TemplateVersionNo = NpXm1TemplateHistory2."Template Version No.") then
            exit;

        NpXm1TemplateHistory.Init();
        NpXm1TemplateHistory."Entry No." := 0;
        NpXm1TemplateHistory."Template Code" := XmlTemplate;
        NpXm1TemplateHistory."Template Version No." := TemplateVersionNo;
        case EventType of
            EventType::New:
                NpXm1TemplateHistory.Description := Text000;
            EventType::Restore:
                NpXm1TemplateHistory.Description := StrSubstNo(Text001, TemplateVersionNo);
            EventType::Modification:
                NpXm1TemplateHistory.Description := Text002;
        end;
        NpXm1TemplateHistory."Version Description" := VersionDescription;
        NpXm1TemplateHistory."Event Type" := EventType;
        NpXm1TemplateHistory."Changed by" := UserId;
        NpXm1TemplateHistory."Change at" := CreateDateTime(Today, Time);
        NpXm1TemplateHistory.Insert();
    end;
}

