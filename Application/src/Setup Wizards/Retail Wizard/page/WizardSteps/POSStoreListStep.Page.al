page 6014653 "NPR POS Store List Step"
{
    Caption = 'POS Stores';
    PageType = ListPart;
    InsertAllowed = false;
    SourceTable = "NPR POS Store";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(POSStoresNo)
            {
                Caption = '';
                field(NoOfPOSStoresToCreate; NoOfPOSStoresToCreate)
                {
                    Caption = 'Number of stores to create: ';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Number of stores to create:  field';

                    trigger OnValidate()
                    var
                        TempAllPOSStore: Record "NPR POS Store" temporary;
                    begin
                        if StartingNoStore <> '' then begin
                            GetRec(TempAllPOSStore);
                            CreateTempPOSStores(NoOfPOSStoresToCreate, StartingNoStore, TempAllPOSStore);

                            NoOfPOSStoresToCreate := 0;
                            StartingNoStore := '';
                        end;
                        CurrPage.Update(false);
                    end;
                }
            }
            group(StartingNoGroup)
            {
                Caption = '';
                InstructionalText = 'In case that the selected Starting No. is taken, the first available No. will be used. That will be applied to all POS Stores.';
            }
            group(POSStoreStartingNo)
            {
                Caption = '';
                field(StartingNo; StartingNoStore)
                {
                    Caption = 'Starting No.: ';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting No.:  field';

                    trigger OnValidate()
                    var
                        TempAllPOSStore: Record "NPR POS Store" temporary;
                    begin
                        if NoOfPOSStoresToCreate <> 0 then begin
                            GetRec(TempAllPOSStore);
                            CreateTempPOSStores(NoOfPOSStoresToCreate, StartingNoStore, TempAllPOSStore);

                            NoOfPOSStoresToCreate := 0;
                            StartingNoStore := '';
                        end;
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PostCode: Record "Post Code";
                        PostCodeList: Page "Post Codes";
                    begin
                        PostCodeList.LookupMode := true;

                        if ("Post Code" <> '') and (City <> '') then
                            if PostCode.Get("Post Code", City) then
                                PostCodeList.SetRecord(PostCode);

                        if PostCodeList.RunModal() = Action::LookupOK then begin
                            PostCodeList.GetRecord(PostCode);
                            "Post Code" := PostCode.Code;
                            City := PostCode.City;
                        end;
                    end;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PostCode: Record "Post Code";
                        PostCodeList: Page "Post Codes";
                    begin
                        PostCodeList.LookupMode := true;

                        if (City <> '') and ("Post Code" <> '') then
                            if PostCode.Get("Post Code", City) then
                                PostCodeList.SetRecord(PostCode);

                        if PostCodeList.RunModal() = Action::LookupOK then begin
                            PostCodeList.GetRecord(PostCode);
                            "Post Code" := PostCode.Code;
                            City := PostCode.City;
                        end;
                    end;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimValue: Record "Dimension Value";
                        DimValueList: Page "Dimension Value List";
                    begin
                        GLSetup.Get();

                        DimValueList.LookupMode := true;

                        DimValue.SetRange("Global Dimension No.", 1);
                        DimValue.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");

                        if DimValue.FindFirst() then;
                        DimValueList.SetTableView(DimValue);

                        if "Global Dimension 1 Code" <> '' then begin
                            DimValue.SetRange(Code, "Global Dimension 1 Code");
                            if DimValue.FindFirst() then
                                DimValueList.SetRecord(DimValue);
                        end;

                        if DimValueList.RunModal() = Action::LookupOK then begin
                            DimValueList.GetRecord(DimValue);
                            "Global Dimension 1 Code" := DimValue.Code;
                        end;
                    end;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimValue: Record "Dimension Value";
                        DimValueList: Page "Dimension Value List";
                    begin
                        GLSetup.Get();

                        DimValueList.LookupMode := true;

                        DimValue.SetRange("Global Dimension No.", 2);
                        DimValue.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");

                        if DimValue.FindFirst() then;
                        DimValueList.SetTableView(DimValue);

                        if "Global Dimension 2 Code" <> '' then begin
                            DimValue.SetRange(Code, "Global Dimension 2 Code");
                            if DimValue.FindFirst() then
                                DimValueList.SetRecord(DimValue);
                        end;

                        if DimValueList.RunModal() = Action::LookupOK then begin
                            DimValueList.GetRecord(DimValue);
                            "Global Dimension 2 Code" := DimValue.Code;
                        end;
                    end;
                }
                field("Default POS Posting Setup"; "Default POS Posting Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Posting Setup field';
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Area Code field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TaxArea: Record "Tax Area";
                        TaxAreas: Page "Tax Area List";
                    begin
                        TaxAreas.LookupMode := true;

                        if "Tax Area Code" <> '' then
                            if TaxArea.Get("Tax Area Code") then
                                TaxAreas.SetRecord(TaxArea);

                        if TaxAreas.RunModal() = Action::LookupOK then begin
                            TaxAreas.GetRecord(TaxArea);
                            "Tax Area Code" := TaxArea.Code;
                        end;
                    end;
                }
                field("Tax Liable"; "Tax Liable")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Liable field';
                }
            }
        }
    }
    var
        GLSetup: Record "General Ledger Setup";
        NoOfPOSStoresToCreate: Integer;
        StartingNoStore: Code[10];

    procedure CreateTempPOSStores(NoOfPOSStores: Integer; StartingNo: Code[10]; var POSStoreTemp: Record "NPR POS Store")
    var
        POSStore: Record "NPR POS Store";
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
        i: Integer;
        LastNoUsed: Code[10];
        RecRef: RecordRef;
    begin
        Rec.Reset();
        LastNoUsed := StartingNo;

        for i := 1 to NoOfPOSStores do begin
            Rec.Init();
            LastNoUsed := CheckIfNoAvailableInPOSStore(POSStore, LastNoUsed);
            LastNoUsed := CheckIfNoAvailableInPOSStore(Rec, LastNoUsed);
            Rec.Code := LastNoUsed;
            Rec.Insert();

            if i = 1 then
                HelperFunctions.FormatCode(LastNoUsed)
            else
                LastNoUsed := IncStr(LastNoUsed);
        end;
    end;

    local procedure CheckIfNoAvailableInPOSStore(var POSStore: Record "NPR POS Store"; var WantedStartingNo: Code[10]) CalculatedNo: Code[10]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        if POSStore.Get(WantedStartingNo) then begin
            HelperFunctions.FormatCode(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInPOSStore(POSStore, WantedStartingNo);
        end;
    end;

    procedure GetRec(var TempPOSStore: Record "NPR POS Store")
    begin
        TempPOSStore.Copy(Rec);
    end;

    procedure SetRec(var TempPOSStore: Record "NPR POS Store")
    begin
        Rec.Copy(TempPOSStore);
    end;

    procedure CopyRealAndTemp(var TempPOSStore: Record "NPR POS Store")
    var
        POSStore: Record "NPR POS Store";
    begin
        TempPOSStore.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempPOSStore := Rec;
                TempPOSStore.Insert();
            until Rec.Next() = 0;

        if POSStore.FindSet() then
            repeat
                TempPOSStore := POSStore;
                TempPOSStore.Insert();
            until POSStore.Next() = 0;
    end;

    procedure POSStoresToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CreatePOSStoreData()
    var
        POSStore: Record "NPR POS Store";
    begin
        if Rec.FindSet() then
            repeat
                POSStore := Rec;
                if not POSStore.Insert() then
                    POSStore.Modify();
            until Rec.Next() = 0;
    end;
}