page 6014552 "NPR Brands WP"
{
    Caption = 'Brands';
    PageType = ListPart;
    UsageCategory = Administration;
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
                field(Id; Id)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInMagBrand(ExistingMagBrands, Id);
                    end;
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

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        ExistingMagBrands: Record "NPR Magento Brand" temporary;

    procedure CopyRealAndTemp(var TempMagentoBrand: Record "NPR Magento Brand")
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

    procedure CreateMagentoBrand()
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

    procedure MagentoBrandToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    local procedure CopyReal()
    var
        MagentoBrand: Record "NPR Magento Brand";
    begin
        if MagentoBrand.FindSet() then
            repeat
                ExistingMagBrands := MagentoBrand;
                ExistingMagBrands.Insert();
            until MagentoBrand.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInMagBrand(var MagBrand: Record "NPR Magento Brand"; var WantedStartingNo: Code[10]) CalculatedNo: Code[10]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        MagBrand.SetRange(Id, CalculatedNo);

        if MagBrand.FindFirst() then begin
            HelperFunctions.FormatCode(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInMagBrand(MagBrand, WantedStartingNo);
        end;
    end;
}