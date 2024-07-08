page 6150877 "NPR Print/Prod Cat. Step"
{
    Extensible = False;
    Caption = 'Print/Production Categories';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR NPRE Print/Prod. Cat.";
    SourceTableTemporary = true;
    UsageCategory = None;

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
                field("Print Tag"; Rec."Print Tag")
                {

                    Visible = ShowPrintTags;
                    ToolTip = 'Specifies the value of the Print Tag field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        ServingStepDiscoveryMethod: Enum "NPR NPRE Serv.Step Discovery";
    begin
        ServingStepDiscoveryMethod := SetupProxy.ServingStepDiscoveryMethod();
        ShowPrintTags := (ServingStepDiscoveryMethod = ServingStepDiscoveryMethod::"Legacy (using print tags)");
    end;

    var
        ShowPrintTags: Boolean;

    internal procedure CopyLiveData()
    var
        PrintProdCategories: Record "NPR NPRE Print/Prod. Cat.";
    begin
        Rec.DeleteAll();

        if PrintProdCategories.FindSet() then
            repeat
                Rec := PrintProdCategories;
                if not Rec.Insert() then
                    Rec.Modify();
            until PrintProdCategories.Next() = 0;
    end;

    internal procedure PrintProdCategoriesToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreatePrintProdCategories()
    var
        PrintProdCategories: Record "NPR NPRE Print/Prod. Cat.";
    begin
        if Rec.FindSet() then
            repeat
                PrintProdCategories := Rec;
                if not PrintProdCategories.Insert() then
                    PrintProdCategories.Modify();
            until Rec.Next() = 0;
    end;
}
