page 6014625 "NPR Brands Select"
{
    Caption = 'Brands';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Magento Brand";
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Brands)
            {
                ShowCaption = false;
                field(Id; Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Id field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Picture; Picture)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture field';
                }
                field("Sorting"; Sorting)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sorting field';
                }
            }
        }
    }

    procedure SetRec(var TempBrand: Record "NPR Magento Brand")
    begin
        Rec.DeleteAll();

        if TempBrand.FindSet() then
            repeat
                Rec := TempBrand;
                Rec.Insert();
            until TempBrand.Next() = 0;

        if Rec.FindSet() then;
    end;
}