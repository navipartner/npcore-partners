page 6151432 "NPR Magento Attr. Labels"
{
    Extensible = False;
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
                        TempBlob: Codeunit "Temp Blob";
                        OutStr: OutStream;
                        InStr: InStream;
                    begin
                        TempBlob.CreateOutStream(OutStr);
                        Rec.CalcFields("Text Field");
                        Rec."Text Field".CreateInStream(InStr);
                        CopyStream(OutStr, InStr);
                        if MagentoFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                            if TempBlob.HasValue() then begin
                                TempBlob.CreateInStream(InStr);
                                Rec."Text Field".CreateOutStream(OutStr);
                                CopyStream(OutStr, InStr);
                            end else
                                Clear(Rec."Text Field");
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
