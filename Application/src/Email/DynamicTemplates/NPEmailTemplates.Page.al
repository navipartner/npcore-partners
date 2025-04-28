#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6185030 "NPR NPEmailTemplates"
{
    Extensible = false;
    Caption = 'NP Email Templates';
    PageType = List;
    ApplicationArea = NPRNPEmailTempl;
    UsageCategory = Lists;
    ModifyAllowed = false;
    CardPageId = "NPR NPEmailTemplateCard";
    SourceTable = "NPR NPEmailTemplate";

    layout
    {
        area(Content)
        {
            repeater(TemplateRepeater)
            {
                field(TemplateId; Rec.TemplateId)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Template Id field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
        }
    }
}
#endif