﻿page 6014625 "NPR Brands Select"
{
    Extensible = False;
    Caption = 'Brands';
    PageType = List;
    UsageCategory = None;

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
                field(Id; Rec.Id)
                {

                    ToolTip = 'Specifies the value of the Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Picture; Rec.Picture)
                {

                    ToolTip = 'Specifies the value of the Picture field';
                    ApplicationArea = NPRRetail;
                }
                field("Sorting"; Rec.Sorting)
                {

                    ToolTip = 'Specifies the value of the Sorting field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure SetRec(var TempBrand: Record "NPR Magento Brand")
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
