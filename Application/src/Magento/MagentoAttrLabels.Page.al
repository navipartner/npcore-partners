page 6151432 "NPR Magento Attr. Labels"
{
    AutoSplitKey = true;
    Caption = 'Attribute Labels';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR Magento Attr. Label";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Value; Rec.Value)
                {

                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Text Field"; Format(Rec."Text Field".HasValue))
                {

                    AssistEdit = true;
                    Caption = 'Text Field';
                    Visible = TextFieldVisible;
                    ToolTip = 'Specifies the value of the Text Field field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        RecRef: RecordRef;
                        FieldRef: FieldRef;
                    begin
                        RecRef.GetTable(Rec);
                        FieldRef := RecRef.Field(Rec.FieldNo("Text Field"));
                        if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                            RecRef.SetTable(Rec);
                            Rec.Modify(true);
                        end;
                    end;
                }
                field("Sorting"; Rec.Sorting)
                {

                    ToolTip = 'Specifies the value of the Sorting field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        MagentoFunctions: Codeunit "NPR Magento Functions";
        TextFieldVisible: Boolean;

    procedure SetTextFieldVisible(NewTextFieldVisible: Boolean)
    begin
        TextFieldVisible := NewTextFieldVisible;
    end;
}