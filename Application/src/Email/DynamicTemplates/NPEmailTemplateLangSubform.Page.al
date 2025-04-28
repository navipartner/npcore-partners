#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6185028 "NPR NPEmailTemplateLangSubform"
{
    Extensible = false;
    PageType = ListPart;
    ApplicationArea = NPRNPEmailTempl;
    SourceTable = "NPR NPEmailTemplateLangMap";

    layout
    {
        area(Content)
        {
            repeater(LangMapRepeater)
            {
                field(LanguageCode; Rec.LanguageCode)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Language Code field.';
                }
                field(LayoutId; Rec.LayoutId)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Layout Id field.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DynamicTemplates: Page "NPR SendGridDynamicTemplates";
                        TempDynamicTemplates2: Record "NPR SendGridDynamicTemplate" temporary;
                    begin
                        DynamicTemplates.LookupMode := true;
                        if (TempDynamicTemplates.Get(Rec.LayoutId)) then;
                        DynamicTemplates.SetSourceTable(TempDynamicTemplates);
                        if (DynamicTemplates.RunModal() <> Action::LookupOK) then
                            exit;

                        DynamicTemplates.GetRecord(TempDynamicTemplates2);
                        Rec.LayoutId := TempDynamicTemplates2.Id;
                        _LayoutName := TempDynamicTemplates2.Name;
                    end;

                    trigger OnValidate()
                    begin
                        TempDynamicTemplates.Get(Rec.LayoutId);
                    end;
                }
                field(LayoutName; _LayoutName)
                {
                    Caption = 'Layout Name';
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Layout Name field.';
                    Editable = false;
                }
            }
        }
    }

    var
        TempDynamicTemplates: Record "NPR SendGridDynamicTemplate" temporary;
        _LayoutName: Text;

    trigger OnAfterGetCurrRecord()
    begin
        Clear(_LayoutName);
        if (TempDynamicTemplates.Get(Rec.LayoutId)) then
            _LayoutName := TempDynamicTemplates.Name;
    end;

    internal procedure SetDynamicTemplates(var Templates: Record "NPR SendGridDynamicTemplate" temporary)
    begin
        TempDynamicTemplates.Copy(Templates, true);
    end;
}
#endif