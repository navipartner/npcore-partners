page 6059880 "NPR POS Store Group Lines"
{
    Extensible = False;
    Caption = 'POS Store Group Lines';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR POS Store Group Line";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                ShowCaption = false;
                field("POS Store"; Rec."POS Store")
                {
                    ToolTip = 'Specifies the value of the POS Store field.';
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