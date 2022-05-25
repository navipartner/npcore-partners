page 6059877 "NPR POS Unit Group Lines"
{
    Extensible = False;
    Caption = 'POS Unit Group Lines';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR POS Unit Group Line";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                ShowCaption = false;
                field("POS Unit"; Rec."POS Unit")
                {
                    ToolTip = 'Specifies the value of the POS Unit field.';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        Rec.CalcFields(Name);
                    end;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}