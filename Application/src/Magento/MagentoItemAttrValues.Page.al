page 6151437 "NPR Magento Item Attr. Values"
{
    Caption = 'Item Attribute Values';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR Magento Item Attr. Value";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Selected; Rec.Selected)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Selected field';

                    trigger OnValidate()
                    var
                        MagentoAttribute: Record "NPR Magento Attribute";
                    begin
                        MagentoAttribute.Get(Rec."Attribute ID");
                        if Rec.Selected then begin
                            if MagentoAttribute.Type in [MagentoAttribute.Type::Single, MagentoAttribute.Type::"Text Area (single)"] then begin
                                Rec.ModifyAll(Selected, false);
                                CurrPage.Update(false);
                                Rec.Find();
                                Rec.Selected := true;
                                Rec.Modify(true);
                            end;
                        end;
                        CurrPage.Update();
                    end;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value field';
                }
            }
        }
    }
}