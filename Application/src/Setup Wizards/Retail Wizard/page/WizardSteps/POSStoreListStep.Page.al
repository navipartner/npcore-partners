page 6014653 "NPR POS Store List Step"
{
    Extensible = False;
    Caption = 'POS Stores';
    PageType = ListPart;
    InsertAllowed = false;
    SourceTable = "NPR POS Store";
    SourceTableTemporary = true;
    UsageCategory = None;

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

                    ToolTip = 'Specifies the value of the Number of stores to create:  field';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Specifies the value of the Starting No.:  field';
                    ApplicationArea = NPRRetail;

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
                field("Code"; Rec.Code)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code"; Rec."Post Code")
                {

                    ToolTip = 'Specifies the value of the Post Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PostCode: Record "Post Code";
                        PostCodeList: Page "Post Codes";
                    begin
                        PostCodeList.LookupMode := true;

                        if (Rec."Post Code" <> '') and (Rec.City <> '') then
                            if PostCode.Get(Rec."Post Code", Rec.City) then
                                PostCodeList.SetRecord(PostCode);

                        if PostCodeList.RunModal() = Action::LookupOK then begin
                            PostCodeList.GetRecord(PostCode);
                            Rec."Post Code" := PostCode.Code;
                            Rec.City := PostCode.City;
                        end;
                    end;
                }
                field(City; Rec.City)
                {

                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PostCode: Record "Post Code";
                        PostCodeList: Page "Post Codes";
                    begin
                        PostCodeList.LookupMode := true;

                        if (Rec.City <> '') and (Rec."Post Code" <> '') then
                            if PostCode.Get(Rec."Post Code", Rec.City) then
                                PostCodeList.SetRecord(PostCode);

                        if PostCodeList.RunModal() = Action::LookupOK then begin
                            PostCodeList.GetRecord(PostCode);
                            Rec."Post Code" := PostCode.Code;
                            Rec.City := PostCode.City;
                        end;
                    end;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;

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

                        if Rec."Global Dimension 1 Code" <> '' then begin
                            DimValue.SetRange(Code, Rec."Global Dimension 1 Code");
                            if DimValue.FindFirst() then
                                DimValueList.SetRecord(DimValue);
                        end;

                        if DimValueList.RunModal() = Action::LookupOK then begin
                            DimValueList.GetRecord(DimValue);
                            Rec."Global Dimension 1 Code" := DimValue.Code;
                        end;
                    end;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;

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

                        if Rec."Global Dimension 2 Code" <> '' then begin
                            DimValue.SetRange(Code, Rec."Global Dimension 2 Code");
                            if DimValue.FindFirst() then
                                DimValueList.SetRecord(DimValue);
                        end;

                        if DimValueList.RunModal() = Action::LookupOK then begin
                            DimValueList.GetRecord(DimValue);
                            Rec."Global Dimension 2 Code" := DimValue.Code;
                        end;
                    end;
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
                HelperFunctions.FormatCode(LastNoUsed, true)
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
            HelperFunctions.FormatCode(WantedStartingNo, true);
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
