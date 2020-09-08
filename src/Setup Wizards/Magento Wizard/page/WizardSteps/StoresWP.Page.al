page 6014522 "NPR Stores WP"
{
    Caption = 'Stores';
    PageType = ListPart;
    SourceTable = "NPR Magento Store";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInMagStore(ExistingMagStores, Code);
                    end;
                }
                field("Website Code"; "Website Code")
                {
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        MagentoWebsites: Page "NPR Websites Select";
                    begin
                        MagentoWebsites.LookupMode := true;
                        MagentoWebsites.Editable := false;

                        MagentoWebsites.SetRec(TempAllMagentoWebsite);

                        IF "Website Code" <> '' then
                            if TempAllMagentoWebsite.Get("Website Code") then
                                MagentoWebsites.SetRecord(TempAllMagentoWebsite);

                        if MagentoWebsites.RunModal() = Action::LookupOK then begin
                            MagentoWebsites.GetRecord(TempAllMagentoWebsite);
                            "Website Code" := TempAllMagentoWebsite.Code;
                        end;
                    end;
                }
                field(Name; Name)
                {
                }
                field("Language Code"; "Language Code")
                {
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Language: Record "Language";
                        Languages: Page "Languages";
                    begin
                        Languages.LookupMode := true;

                        IF "Language Code" <> '' then
                            if Language.Get("Language Code") then
                                Languages.SetRecord(Language);

                        if Languages.RunModal() = Action::LookupOK then begin
                            Languages.GetRecord(Language);
                            "Language Code" := Language.Code;
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
        ExistingMagStores: Record "NPR Magento Store" temporary;
        TempAllMagentoWebsite: Record "NPR Magento Website" temporary;

    procedure SetGlobals(var TempMagentoWebsite: Record "NPR Magento Website")
    begin
        TempAllMagentoWebsite.DeleteAll();

        if TempMagentoWebsite.FindSet() then
            repeat
                TempAllMagentoWebsite := TempMagentoWebsite;
                TempAllMagentoWebsite.Insert();
            until TempMagentoWebsite.Next() = 0;
    end;

    procedure CreateMagentoStoreData()
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

    procedure MagentoStoreDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    local procedure CopyReal()
    var
        MagentoStore: Record "NPR Magento Store";
    begin
        if MagentoStore.FindSet() then
            repeat
                ExistingMagStores := MagentoStore;
                ExistingMagStores.Insert();
            until MagentoStore.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInMagStore(var MagStore: Record "NPR Magento Store"; var WantedStartingNo: Code[10]) CalculatedNo: Code[10]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        MagStore.SetRange(Code, CalculatedNo);

        if MagStore.FindFirst() then begin
            HelperFunctions.FormatCode(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInMagStore(MagStore, WantedStartingNo);
        end;
    end;
}