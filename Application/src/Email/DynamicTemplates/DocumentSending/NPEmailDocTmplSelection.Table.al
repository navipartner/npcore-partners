table 6248730 "NPR NPEmailDocTmplSelection"
{
    Access = Internal;
    Caption = 'NP Email Doc. Template Selection';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Document Type"; Enum "NPR NPEmailDocType")
        {
            Caption = 'Document Type';

            trigger OnValidate()
            begin
                ErrorIfDuplicateDocumentType();
            end;
        }
        field(3; "Email Template Id"; Code[20])
        {
            Caption = 'Email Template Id';
            TableRelation = "NPR NPEmailTemplate".TemplateId;

            trigger OnValidate()
            var
                NPEmailTemplate: Record "NPR NPEmailTemplate";
                IDocType: Interface "NPR INPEmailDocType";
                ExpectedDataProvider: Enum "NPR DynTemplateDataProvider";
                TemplateProviderMismatchErr: Label 'The selected %1 ''%2'' uses %3 ''%4'', but %5 ''%6'' requires %3 ''%7''.', Comment = '%1 = Email Template Id caption, %2 = template id, %3 = Data Provider caption, %4 = template data provider, %5 = Document Type caption, %6 = document type, %7 = expected data provider';
            begin
                if Rec."Email Template Id" = '' then
                    exit;
                NPEmailTemplate.Get(Rec."Email Template Id");
                IDocType := Rec."Document Type";
                ExpectedDataProvider := IDocType.GetDataProvider();
                if NPEmailTemplate.DataProvider <> ExpectedDataProvider then
                    Error(
                        TemplateProviderMismatchErr,
                        Rec.FieldCaption("Email Template Id"), Rec."Email Template Id",
                        NPEmailTemplate.FieldCaption(DataProvider), Format(NPEmailTemplate.DataProvider),
                        Rec.FieldCaption("Document Type"), Format(Rec."Document Type"),
                        Format(ExpectedDataProvider));
            end;
        }
        field(4; "Email Template Description"; Text[100])
        {
            Caption = 'Email Template Description';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR NPEmailTemplate".Description where(TemplateId = field("Email Template Id")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        ErrorIfDuplicateDocumentType();
    end;

    trigger OnModify()

    begin
        ErrorIfDuplicateDocumentType();

    end;

    local procedure ErrorIfDuplicateDocumentType()
    var
        DocTmplSelection: Record "NPR NPEmailDocTmplSelection";
        DuplicateDocTypeErr: Label 'A template is already set up for %1 ''%2''. Only one template can be configured per %1.', Comment = '%1 = Document Type field caption, %2 = document type value';
    begin
        DocTmplSelection.SetRange("Document Type", Rec."Document Type");
        DocTmplSelection.SetFilter("Entry No.", '<>%1', Rec."Entry No.");
        if not DocTmplSelection.IsEmpty() then
            Error(DuplicateDocTypeErr, Rec.FieldCaption("Document Type"), Format(Rec."Document Type"));
    end;
}
