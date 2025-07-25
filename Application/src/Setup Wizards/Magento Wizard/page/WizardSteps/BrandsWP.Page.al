﻿page 6014552 "NPR Brands WP"
{
    Extensible = False;
    Caption = 'Brands';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Brand";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Brands)
            {
                ShowCaption = false;
                field(Id; Rec.Id)
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Id field';
                    ApplicationArea = NPRMagento;

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInMagBrand(TempExistingMagBrands, Rec.Id);
                    end;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRMagento;
                }
                field(Picture; Rec.Picture)
                {

                    ToolTip = 'Specifies the value of the Picture field';
                    ApplicationArea = NPRMagento;
                }
                field("Sorting"; Rec.Sorting)
                {

                    ToolTip = 'Specifies the value of the Sorting field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        TempExistingMagBrands: Record "NPR Magento Brand" temporary;

    internal procedure CopyRealAndTemp(var TempMagentoBrand: Record "NPR Magento Brand")
    var
        MagentoBrand: Record "NPR Magento Brand";
    begin
        TempMagentoBrand.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempMagentoBrand := Rec;
                TempMagentoBrand.Insert();
            until Rec.Next() = 0;

        TempMagentoBrand.Init();
        if MagentoBrand.FindSet() then
            repeat
                TempMagentoBrand.TransferFields(MagentoBrand);
                TempMagentoBrand.Insert();
            until MagentoBrand.Next() = 0;
    end;

    internal procedure CreateMagentoBrand()
    var
        MagentoBrand: Record "NPR Magento Brand";
    begin
        if Rec.FindSet() then
            repeat
                MagentoBrand := Rec;
                if not MagentoBrand.Insert() then
                    MagentoBrand.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure MagentoBrandToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    local procedure CopyReal()
    var
        MagentoBrand: Record "NPR Magento Brand";
    begin
        if MagentoBrand.FindSet() then
            repeat
                TempExistingMagBrands := MagentoBrand;
                TempExistingMagBrands.Insert();
            until MagentoBrand.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInMagBrand(var MagBrand: Record "NPR Magento Brand"; var WantedStartingNo: Code[20]) CalculatedNo: Code[20]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        MagBrand.SetRange(Id, CalculatedNo);

        if MagBrand.FindFirst() then begin
            WantedStartingNo := HelperFunctions.FormatCode20(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInMagBrand(MagBrand, WantedStartingNo);
        end;
    end;
}
