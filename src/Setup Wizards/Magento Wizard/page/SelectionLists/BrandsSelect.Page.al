page 6014625 "NPR Brands Select"
{
    Caption = 'Brands';
    PageType = List;
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
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Picture; Picture)
                {
                    ApplicationArea = All;
                }
                field("Sorting"; Sorting)
                {
                    ApplicationArea = All;
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