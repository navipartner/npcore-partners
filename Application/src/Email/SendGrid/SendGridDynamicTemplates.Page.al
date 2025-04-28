#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6185025 "NPR SendGridDynamicTemplates"
{
    Extensible = false;
    Caption = 'NP Email Dynamic Templates';
    PageType = List;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;
    ApplicationArea = NPRNPEmailTempl;
    SourceTable = "NPR SendGridDynamicTemplate";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(TemplateRepeater)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Id field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Name field.';
                }
            }
        }
    }

    internal procedure SetSourceTable(var Templates: Record "NPR SendGridDynamicTemplate")
    begin
        Rec.Copy(Templates, true);
    end;
}
#endif