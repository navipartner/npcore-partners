#if not (BC17 or BC18 or BC19 or BC20 or BC21)
table 6151119 "NPR NPEmailTemplateLangMap"
{
    Access = Internal;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; TemplateId; Code[20])
        {
            Caption = 'Template Id';
            NotBlank = true;
        }
        field(2; LanguageCode; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language.Code;
            NotBlank = true;
        }
        field(3; LayoutId; Text[50])
        {
            Caption = 'Layout Id';
            TableRelation = "NPR SendGridDynamicTemplate".Id;
        }
    }

    keys
    {
        key(PK; TemplateId, LanguageCode)
        {
            Clustered = true;
        }
    }
}
#endif