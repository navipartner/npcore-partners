page 6185033 "NPR SG ItemsProfile"
{
    Extensible = false;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR SG ItemsProfile";
    Caption = 'Speedgate Items Profile';

    layout
    {
        area(Content)
        {
            field("Code"; Rec."Code")
            {
                ToolTip = 'Specifies the value of the Code field.';
                ApplicationArea = NPRRetail;
            }
            field(Description; Rec.Description)
            {
                ToolTip = 'Specifies the value of the Description field.';
                ApplicationArea = NPRRetail;
            }
            part(ItemProfileLines; "NPR SG ItemsProfileLine")
            {
                Caption = 'Item Profile Lines';
                ApplicationArea = NPRRetail;
                SubPageLink = Code = field("Code");
                SubPageView = sorting(Code, LineNo);
            }

        }
    }
}