page 6151462 "NPR Magento Setup PostOnImport"
{
    Caption = 'Post on Import Setup';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento PostOnImport Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }
}