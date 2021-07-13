page 6014626 "NPR Displ Groups Select"
{
    Caption = 'Display Groups';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Display Group";
    SourceTableTemporary = true;
    Editable = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
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

    procedure SetRec(var TempDisplayGroup: Record "NPR Magento Display Group")
    begin
        Rec.DeleteAll();

        if TempDisplayGroup.FindSet() then
            repeat
                Rec := TempDisplayGroup;
                Rec.Insert();
            until TempDisplayGroup.Next() = 0;

        if Rec.FindSet() then;
    end;
}
