﻿page 6014522 "NPR Stores WP"
{
    Extensible = False;
    Caption = 'Stores';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Store";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMagento;

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInMagStore(TempExistingMagStores, Rec.Code);
                    end;
                }
                field("Website Code"; Rec."Website Code")
                {

                    ToolTip = 'Specifies the value of the Website Code field';
                    ApplicationArea = NPRMagento;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        MagentoWebsites: Page "NPR Websites Select";
                    begin
                        MagentoWebsites.LookupMode := true;
                        MagentoWebsites.Editable := false;

                        MagentoWebsites.SetRec(TempAllMagentoWebsite);

                        IF Rec."Website Code" <> '' then
                            if TempAllMagentoWebsite.Get(Rec."Website Code") then
                                MagentoWebsites.SetRecord(TempAllMagentoWebsite);

                        if MagentoWebsites.RunModal() = Action::LookupOK then begin
                            MagentoWebsites.GetRecord(TempAllMagentoWebsite);
                            Rec."Website Code" := TempAllMagentoWebsite.Code;
                        end;
                    end;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRMagento;
                }
                field("Language Code"; Rec."Language Code")
                {

                    ToolTip = 'Specifies the value of the Language Code field';
                    ApplicationArea = NPRMagento;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Language: Record "Language";
                        Languages: Page "Languages";
                    begin
                        Languages.LookupMode := true;

                        IF Rec."Language Code" <> '' then
                            if Language.Get(Rec."Language Code") then
                                Languages.SetRecord(Language);

                        if Languages.RunModal() = Action::LookupOK then begin
                            Languages.GetRecord(Language);
                            Rec."Language Code" := Language.Code;
                        end;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        TempExistingMagStores: Record "NPR Magento Store" temporary;
        TempAllMagentoWebsite: Record "NPR Magento Website" temporary;

    internal procedure SetGlobals(var TempMagentoWebsite: Record "NPR Magento Website")
    begin
        TempAllMagentoWebsite.DeleteAll();

        if TempMagentoWebsite.FindSet() then
            repeat
                TempAllMagentoWebsite := TempMagentoWebsite;
                TempAllMagentoWebsite.Insert();
            until TempMagentoWebsite.Next() = 0;
    end;

    internal procedure CreateMagentoStoreData()
    var
        MagentoStore: Record "NPR Magento Store";
    begin
        if Rec.FindSet() then
            repeat
                MagentoStore := Rec;
                if not MagentoStore.Insert() then
                    MagentoStore.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure MagentoStoreDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    local procedure CopyReal()
    var
        MagentoStore: Record "NPR Magento Store";
    begin
        if MagentoStore.FindSet() then
            repeat
                TempExistingMagStores := MagentoStore;
                TempExistingMagStores.Insert();
            until MagentoStore.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInMagStore(var MagStore: Record "NPR Magento Store"; var WantedStartingNo: Code[32]) CalculatedNo: Code[32]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        MagStore.SetRange(Code, CalculatedNo);

        if MagStore.FindFirst() then begin
            HelperFunctions.FormatCode32(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInMagStore(MagStore, WantedStartingNo);
        end;
    end;
}
