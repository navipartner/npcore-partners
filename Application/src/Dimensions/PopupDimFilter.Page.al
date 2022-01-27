page 6014556 "NPR Popup Dim. Filter"
{
    Extensible = False;

    Caption = 'Popup Dimension Filter';
    PageType = ListPart;
    SourceTable = "NPR Popup Dim. Filter";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}
