page 6151432 "NPR Magento Attr. Labels"
{
    // MAG1.01/MH/20150201  CASE 199932 Refactored Object from Web Integration
    // MAG1.04/MH/20150206  CASE 199932 Removed Image
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    AutoSplitKey = true;
    Caption = 'Attribute Labels';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ShowFilter = false;
    SourceTable = "NPR Magento Attr. Label";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Value; Value)
                {
                    ApplicationArea = All;
                }
                field("FORMAT(""Text Field"".HASVALUE)"; Format("Text Field".HasValue))
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Caption = 'Text Field';
                    Visible = TextFieldVisible;

                    trigger OnAssistEdit()
                    var
                        RecRef: RecordRef;
                        FieldRef: FieldRef;
                    begin
                        RecRef.GetTable(Rec);
                        FieldRef := RecRef.Field(FieldNo("Text Field"));
                        if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                            RecRef.SetTable(Rec);
                            Modify(true);
                        end;
                    end;
                }
                field("Sorting"; Sorting)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    var
        MagentoFunctions: Codeunit "NPR Magento Functions";
        TextFieldVisible: Boolean;

    procedure SetTextFieldVisible(NewTextFieldVisible: Boolean)
    begin
        TextFieldVisible := NewTextFieldVisible;
    end;
}

