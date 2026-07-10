page 6248732 "NPR NPEmailDocTmplSelections"
{
    Caption = 'NP Email Document Template Selections';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = NPRNPEmailTempl;
    SourceTable = "NPR NPEmailDocTmplSelection";
    Extensible = false;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group("Filter")
            {
                Caption = 'Filter';

                field(DocumentTypeFilter; _DocumentType)
                {
                    Caption = 'Document Type';
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the document type to show NP Email templates for. Change it to set up another document type.';
                    ValuesAllowed = "Posted Sales Invoice";

                    trigger OnValidate()
                    begin
                        SetDocumentTypeFilter();
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Lines)
            {
                field("Email Template Id"; Rec."Email Template Id")
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the NP Email template used to send this document type.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        NPEmailTemplate: Record "NPR NPEmailTemplate";
                        NPEmailTemplates: Page "NPR NPEmailTemplates";
                        IDocType: Interface "NPR INPEmailDocType";
                    begin
                        IDocType := Rec."Document Type";
                        NPEmailTemplate.SetRange(DataProvider, IDocType.GetDataProvider());
                        NPEmailTemplates.SetTableView(NPEmailTemplate);
                        NPEmailTemplates.LookupMode := true;
                        if NPEmailTemplates.RunModal() <> Action::LookupOK then
                            exit(false);
                        NPEmailTemplates.GetRecord(NPEmailTemplate);
                        Rec.Validate("Email Template Id", NPEmailTemplate.TemplateId);
                        // Value is applied to Rec above; return false so the platform does not overwrite
                        // the field with the (unset) Text parameter.
                        exit(false);
                    end;
                }
                field("Email Template Description"; Rec."Email Template Description")
                {
                    ApplicationArea = NPRNPEmailTempl;
                    Editable = false;
                    ToolTip = 'Specifies the description of the selected NP Email template.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if _DocumentType = Enum::"NPR NPEmailDocType"::Undefined then
            _DocumentType := Enum::"NPR NPEmailDocType"::"Posted Sales Invoice";


        SetDocumentTypeFilter();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Document Type" := _DocumentType;
    end;

    var
        _DocumentType: Enum "NPR NPEmailDocType";

    local procedure SetDocumentTypeFilter()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Document Type", _DocumentType);
        Rec.FilterGroup(0);
    end;
}
