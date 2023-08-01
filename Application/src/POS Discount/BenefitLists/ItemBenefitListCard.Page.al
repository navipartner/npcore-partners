page 6151091 "NPR Item Benefit List Card"
{
    Extensible = false;
    Caption = 'Item Benefit List Card';
    PageType = Document;
    UsageCategory = None;
    SourceTable = "NPR Item Benefit List Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code of the Item Benefit List.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the description of the Item Benefit List';
                }
            }

            part(SubForm; "NPR Item Benefit List Subform")
            {
                Caption = 'Item Benefit List Subform';
                ShowFilter = false;
                Editable = LinesEditable;
                SubPageLink = "List Code" = FIELD(Code);
                UpdatePropagation = Both;
                ApplicationArea = NPRRetail;
            }
        }


    }

    var
        LinesEditable: Boolean;


    trigger OnAfterGetCurrRecord()
    begin
        LinesEditable := Rec.Code <> '';
    end;

}