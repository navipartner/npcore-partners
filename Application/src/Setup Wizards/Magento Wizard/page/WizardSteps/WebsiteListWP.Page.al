page 6014520 "NPR Website List WP"
{
    Caption = 'Websites';
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Website";
    SourceTableTemporary = true;
    DelayedInsert = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Websites)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Website"; Rec."Default Website")
                {

                    ToolTip = 'Specifies the value of the Std. Website field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GlobalDimension1: Record "Dimension Value";
                        GlobalDimensions: Page "Dimension Value List";
                    begin
                        GlobalDimensions.LookupMode := true;

                        IF Rec."Global Dimension 1 Code" <> '' then begin
                            GlobalDimension1.SetRange("Global Dimension No.", 1);
                            GlobalDimension1.SetRange(Code, Rec."Global Dimension 1 Code");
                            if GlobalDimension1.FindFirst() then
                                GlobalDimensions.SetRecord(GlobalDimension1);
                        end;

                        if GlobalDimensions.RunModal() = Action::LookupOK then begin
                            GlobalDimensions.GetRecord(GlobalDimension1);
                            Rec."Global Dimension 1 Code" := GlobalDimension1.Code;
                        end;
                    end;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GlobalDimension2: Record "Dimension Value";
                        GlobalDimensions: Page "Dimension Value List";
                    begin
                        GlobalDimensions.LookupMode := true;
                        GlobalDimensions.Editable := false;

                        IF Rec."Global Dimension 2 Code" <> '' then begin
                            GlobalDimension2.SetRange("Global Dimension No.", 2);
                            GlobalDimension2.SetRange(Code, Rec."Global Dimension 2 Code");
                            if GlobalDimension2.FindFirst() then
                                GlobalDimensions.SetRecord(GlobalDimension2);
                        end;

                        if GlobalDimensions.RunModal() = Action::LookupOK then begin
                            GlobalDimensions.GetRecord(GlobalDimension2);
                            Rec."Global Dimension 2 Code" := GlobalDimension2.Code;
                        end;
                    end;
                }
            }
        }
    }
    procedure CreateMagentoWebsiteData()
    var
        MagentoWebsite: Record "NPR Magento Website";
    begin
        if Rec.FindSet() then
            repeat
                MagentoWebsite := Rec;
                if not MagentoWebsite.Insert() then
                    MagentoWebsite.Modify();
            until Rec.Next() = 0;
    end;

    procedure MagentoWebsiteDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CopyRealAndTemp(var TempMagentoWebsite: Record "NPR Magento Website")
    var
        MagentoWebsite: Record "NPR Magento Website";
    begin
        TempMagentoWebsite.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempMagentoWebsite := Rec;
                TempMagentoWebsite.Insert();
            until Rec.Next() = 0;

        TempMagentoWebsite.Init();
        if MagentoWebsite.FindSet() then
            repeat
                TempMagentoWebsite.TransferFields(MagentoWebsite);
                TempMagentoWebsite.Insert();
            until MagentoWebsite.Next() = 0;
    end;
}
