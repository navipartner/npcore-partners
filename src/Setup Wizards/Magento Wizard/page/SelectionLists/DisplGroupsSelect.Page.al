page 6014626 "NPR Displ Groups Select"
{
    Caption = 'Display Groups';
    PageType = List;
    SourceTable = "NPR Magento Display Group";
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                }
                field(Description; Description)
                {
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