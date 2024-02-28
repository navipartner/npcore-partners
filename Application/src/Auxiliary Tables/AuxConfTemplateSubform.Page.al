
page 6059859 "NPR Aux Conf. Template Subform"
{
    Extensible = False;
    PageType = ListPart;
    SourceTable = "Config. Template Line";
#IF BC17 or BC18 or BC19 or BC20 or BC21
    UsageCategory = None;

    [Obsolete('Only available in cloud version', 'NPR23.0')]
    procedure SetAuxTableId(_AuxTableId: Integer)
    begin
    end;
#endif
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC21)
    AutoSplitKey = true;
    Caption = 'Aux Lines';
    LinksAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the type of data in the data template.';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the name of the field in the data template.';

                    trigger OnAssistEdit()
                    begin
                        NPRSelectFieldName();
                    end;
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the caption of the field on which the data template is based. The caption comes from the Caption property of the field.';
                }
                field("Template Code"; Rec."Template Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code for the data template.';
                }
                field("Default Value"; Rec."Default Value")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the default value with reference to the data template line.';
                }
                field("Skip Relation Check"; Rec."Skip Relation Check")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies that the relationship between the table fields should not be checked. This can useful when you want to specify a value for a field that is not yet available. For example, you may want to specify a value for a payment term that is not available in the table on which you are basing you configuration. You can specify that value, select the Skip Relation Check box, and then continue to apply data without error.';
                }
                field(Mandatory; Rec.Mandatory)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether it is required that there be data in the field in the data template. By default, the check box is selected to make a value mandatory. You can clear the check box.';
                }
                field(Reference; Rec.Reference)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a url address. Use this field to provide a url address to a location that specifies additional information about the field in the data template. For example, you could provide the address that specifies information on setup considerations that the solution implementer should consider.';
                }
            }
        }
    }

    var
        AuxTableId: Integer;

    trigger OnOpenPage()
    begin
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
    end;

    procedure SetAuxTableId(_AuxTableId: Integer)
    begin
        AuxTableId := _AuxTableId;
    end;

    local procedure NPRSelectFieldName()
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        Field: Record Field;
        FieldSelection: Codeunit "Field Selection";
    begin
        if Rec.Type = Rec.Type::Template then
            exit;

        ConfigTemplateHeader.Get(Rec."Data Template Code");

        ConfigTemplateHeader."Table ID" := AuxTableId;
        if ConfigTemplateHeader."Table ID" = 0 then
            exit;

        NPRSetFieldFilter(Field, ConfigTemplateHeader."Table ID", 0);
        if FieldSelection.Open(Field) then begin
            Rec."Table ID" := Field.TableNo;
            Rec.Validate("Field ID", Field."No.");
            Rec.Validate("Field Name", Field.FieldName);
        end;
    end;

    local procedure NPRSetFieldFilter(var "Field": Record "Field"; TableID: Integer; FieldID: Integer)
    begin
        Field.Reset();
        if TableID > 0 then
            Field.SetRange(TableNo, TableID);
        if FieldID > 0 then
            Field.SetRange("No.", FieldID);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(Enabled, true);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
    end;
#endif
}
