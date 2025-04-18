page 6014683 "NPR POS Unit List Step"
{
    Extensible = False;
    Caption = 'POS Units';
    PageType = ListPart;
    SourceTable = "NPR POS Unit";
    SourceTableTemporary = true;
    InsertAllowed = false;
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used anymore. Retail wizard was modified.';

    layout
    {
        area(content)
        {

            group(POSStoreSelection)
            {
                Caption = 'Select POS Store';
                field(POSStoreCode; _SelectedPOSStore)
                {
                    ShowMandatory = true;
                    Caption = 'POS Store Code';

                    Lookup = true;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        NoOfPOSUnitsToCreate := 0;
                        StartingNoUnit := '';

                        if Page.RunModal(Page::"NPR POS Stores Select", TempAllPOSStore) = Action::LookupOK then begin
                            _SelectedPOSStore := TempAllPOSStore.Code;
                            CurrPage.Update(false);
                        end;

                        Rec.SetRange("POS Store Code", _SelectedPOSStore);
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Empty)
            {
                Caption = '';
                InstructionalText = ' ';
            }
            group(POSUnitNoOfUnits)
            {
                Caption = 'POS Unit information';
                field(NoOfPOSUnits; NoOfPOSUnitsToCreate)
                {
                    Caption = 'Number of units to create';

                    ToolTip = 'Specifies the value of the Number of units to create field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (StartingNoUnit <> '') and (_SelectedPOSStore <> '') then begin
                            GetRec(TempPOSUnit_);
                            CreateTempPOSUnits(NoOfPOSUnitsToCreate, StartingNoUnit, _SelectedPOSStore, TempPOSUnit_);

                            NoOfPOSUnitsToCreate := 0;
                            StartingNoUnit := '';
                        end;
                        Rec.SetRange("POS Store Code", _SelectedPOSStore);
                        CurrPage.Update(false);
                    end;
                }
            }
            group(StartingNoGroup)
            {
                Caption = '';
                InstructionalText = 'In case that the selected Starting No. is taken, the first available No. will be used. That will be applied to all POS Units.';
            }
            group(POSUnitStartingNo)
            {
                Caption = '';
                field(StartingNoUnit; StartingNoUnit)
                {
                    Caption = 'Starting No.';

                    ToolTip = 'Specifies the value of the Starting No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (NoOfPOSUnitsToCreate <> 0) and (_SelectedPOSStore <> '') then begin
                            GetRec(TempPOSUnit_);
                            CreateTempPOSUnits(NoOfPOSUnitsToCreate, StartingNoUnit, _SelectedPOSStore, TempPOSUnit_);

                            NoOfPOSUnitsToCreate := 0;
                            StartingNoUnit := '';
                        end;
                        Rec.SetRange("POS Store Code", _SelectedPOSStore);
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimen 1 Code"; Rec."Global Dimension 1 Code")
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
                            Rec.Modify(false);
                        end;
                    end;
                }
                field("Global Dime 2 Code"; Rec."Global Dimension 2 Code")
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
                            Rec.Modify(false);
                        end;
                    end;
                }
                field(Status; Rec.Status)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Audit Profile"; Rec."POS Audit Profile")
                {

                    ToolTip = 'Specifies the value of the POS Audit Profile field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempAllPOSAuditProfileList: Page "NPR POS Audit Prof. Select";
                    begin
                        TempAllPOSAuditProfileList.LookupMode := true;
                        TempAllPOSAuditProfileList.Editable := false;
                        TempAllPOSAuditProfileList.SetRec(TempAllPOSAuditProfile);

                        if Rec."POS Audit Profile" <> '' then
                            if TempAllPOSAuditProfile.Get(Rec."POS Audit Profile") then
                                TempAllPOSAuditProfileList.SetRecord(TempAllPOSAuditProfile);

                        if TempAllPOSAuditProfileList.RunModal() = Action::LookupOK then begin
                            TempAllPOSAuditProfileList.GetRecord(TempAllPOSAuditProfile);
                            Rec."POS Audit Profile" := TempAllPOSAuditProfile.Code;
                        end;
                    end;
                }
                field("POS View Profile"; Rec."POS View Profile")
                {

                    ToolTip = 'Specifies the value of the POS View Profile field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempAllPOSViewProfileList: Page "NPR POS View Prof. Select";
                    begin
                        TempAllPOSViewProfileList.LookupMode := true;
                        TempAllPOSViewProfileList.Editable := false;
                        TempAllPOSViewProfileList.SetRec(TempAllPOSViewProfile);

                        if Rec."POS View Profile" <> '' then
                            if TempAllPOSViewProfile.Get(Rec."POS View Profile") then
                                TempAllPOSViewProfileList.SetRecord(TempAllPOSViewProfile);

                        if TempAllPOSViewProfileList.RunModal() = Action::LookupOK then begin
                            TempAllPOSViewProfileList.GetRecord(TempAllPOSViewProfile);
                            Rec."POS View Profile" := TempAllPOSViewProfile.Code;
                        end;
                    end;
                }
                field("POS End of Day Profile"; Rec."POS End of Day Profile")
                {

                    ToolTip = 'Specifies the value of the POS End of Day Profile field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempAllPOSEndOfDayProfileList: Page "NPR POS EOD Prof. Select";
                    begin
                        TempAllPOSEndOfDayProfileList.LookupMode := true;
                        TempAllPOSEndOfDayProfileList.Editable := false;
                        TempAllPOSEndOfDayProfileList.SetRec(TempAllPOSEndOfDayProfile);

                        if Rec."POS End of Day Profile" <> '' then
                            if TempAllPOSEndOfDayProfile.Get(Rec."POS End of Day Profile") then
                                TempAllPOSEndOfDayProfileList.SetRecord(TempAllPOSEndOfDayProfile);

                        if TempAllPOSEndOfDayProfileList.RunModal() = Action::LookupOK then begin
                            TempAllPOSEndOfDayProfileList.GetRecord(TempAllPOSEndOfDayProfile);
                            Rec."POS End of Day Profile" := TempAllPOSEndOfDayProfile.Code;
                        end;
                    end;
                }
                field("Ean Box Sales Setup"; Rec."Ean Box Sales Setup")
                {

                    ToolTip = 'Specifies the value of the Ean Box Sales Setup field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempAllEanBoxSetupList: Page "NPR Ean Box Setups Select";
                    begin
                        TempAllEanBoxSetupList.LookupMode := true;
                        TempAllEanBoxSetupList.Editable := false;
                        TempAllEanBoxSetupList.SetRec(TempAllEanBoxSetup);

                        if Rec."Ean Box Sales Setup" <> '' then
                            if TempAllEanBoxSetup.Get(Rec."Ean Box Sales Setup") then
                                TempAllEanBoxSetupList.SetRecord(TempAllEanBoxSetup);

                        if TempAllEanBoxSetupList.RunModal() = Action::LookupOK then begin
                            TempAllEanBoxSetupList.GetRecord(TempAllEanBoxSetup);
                            Rec."Ean Box Sales Setup" := TempAllEanBoxSetup.Code;
                        end;
                    end;
                }
                field("POS Sales Workflow Set"; Rec."POS Sales Workflow Set")
                {

                    ToolTip = 'Specifies the value of the POS Sales Workflow Set field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempAllPOSSalesWorkflowSetList: Page "NPR POS Sal. Workfl. Set. Sel.";
                    begin
                        TempAllPOSSalesWorkflowSetList.LookupMode := true;
                        TempAllPOSSalesWorkflowSetList.Editable := false;
                        TempAllPOSSalesWorkflowSetList.SetRec(TempAllPOSSalesWorkflowSet);

                        if Rec."POS Sales Workflow Set" <> '' then
                            if TempAllPOSSalesWorkflowSet.Get(Rec."POS Sales Workflow Set") then
                                TempAllPOSSalesWorkflowSetList.SetRecord(TempAllPOSSalesWorkflowSet);

                        if TempAllPOSSalesWorkflowSetList.RunModal() = Action::LookupOK then begin
                            TempAllPOSSalesWorkflowSetList.GetRecord(TempAllPOSSalesWorkflowSet);
                            Rec."POS Sales Workflow Set" := TempAllPOSSalesWorkflowSet.Code;
                        end;
                    end;
                }
                field("Global POS Sales Setup"; Rec."Global POS Sales Setup")
                {

                    ToolTip = 'Specifies the value of the Global POS Sales Setup field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempAllGlobalPOSSalesSetupList: Page "NPR Glob. POS Sal. Setups Sel.";
                    begin
                        TempAllGlobalPOSSalesSetupList.LookupMode := true;
                        TempAllGlobalPOSSalesSetupList.Editable := false;
                        TempAllGlobalPOSSalesSetupList.SetRec(TempAllGlobalPOSSalesSetup);

                        if Rec."Global POS Sales Setup" <> '' then
                            if TempAllGlobalPOSSalesSetup.Get(Rec."Global POS Sales Setup") then
                                TempAllGlobalPOSSalesSetupList.SetRecord(TempAllGlobalPOSSalesSetup);

                        if TempAllGlobalPOSSalesSetupList.RunModal() = Action::LookupOK then begin
                            TempAllGlobalPOSSalesSetupList.GetRecord(TempAllGlobalPOSSalesSetup);
                            Rec."Global POS Sales Setup" := TempAllGlobalPOSSalesSetup.Code;
                        end;
                    end;
                }
            }
        }
    }

    var
        TempPOSUnit_: Record "NPR POS Unit" temporary;
        TempAllPOSStore: Record "NPR POS Store" temporary;
        TempAllPOSAuditProfile: Record "NPR POS Audit Profile" temporary;
        TempAllPOSViewProfile: Record "NPR POS View Profile" temporary;
        TempAllPOSEndOfDayProfile: Record "NPR POS End of Day Profile" temporary;
        TempAllPOSPostingProfile: Record "NPR POS Posting Profile" temporary;
        TempAllEanBoxSetup: Record "NPR Ean Box Setup" temporary;
        TempAllPOSSalesWorkflowSet: Record "NPR POS Sales Workflow Set" temporary;
        TempAllGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup" temporary;
        GLSetup: Record "General Ledger Setup";
        NoOfPOSUnitsToCreate: Integer;
        StartingNoUnit: Code[10];
        _SelectedPOSStore: Code[10];

    internal procedure SetGlobals(var POSStoreAll: Record "NPR POS Store";
                         var POSAuditProfile: Record "NPR POS Audit Profile";
                         var POSViewProfile: Record "NPR POS View Profile";
                         var POSEndOfDayProfile: Record "NPR POS End of Day Profile";
                         var POSPostingProfile: Record "NPR POS Posting Profile";
                         var EanBoxSetup: Record "NPR Ean Box Setup";
                         var POSSalesWorkflowSet: Record "NPR POS Sales Workflow Set";
                         var GlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    begin
        TempAllPOSStore.DeleteAll();
        if POSStoreAll.FindSet() then
            repeat
                TempAllPOSStore := POSStoreAll;
                TempAllPOSStore.Insert();
            until POSStoreAll.Next() = 0;
        if TempAllPOSStore.FindSet() then;

        TempAllPOSAuditProfile.DeleteAll();
        if POSAuditProfile.FindSet() then
            repeat
                TempAllPOSAuditProfile := POSAuditProfile;
                TempAllPOSAuditProfile.Insert();
            until POSAuditProfile.Next() = 0;
        if TempAllPOSAuditProfile.FindSet() then;

        TempAllPOSViewProfile.DeleteAll();
        if POSViewProfile.FindSet() then
            repeat
                TempAllPOSViewProfile := POSViewProfile;
                TempAllPOSViewProfile.Insert();
            until POSViewProfile.Next() = 0;
        if TempAllPOSViewProfile.FindSet() then;

        TempAllPOSEndOfDayProfile.DeleteAll();
        if POSEndOfDayProfile.FindSet() then
            repeat
                TempAllPOSEndOfDayProfile := POSEndOfDayProfile;
                TempAllPOSEndOfDayProfile.Insert();
            until POSEndOfDayProfile.Next() = 0;
        if TempAllPOSEndOfDayProfile.FindSet() then;

        TempAllPOSPostingProfile.DeleteAll();
        if POSPostingProfile.FindSet() then
            repeat
                TempAllPOSPostingProfile := POSPostingProfile;
                TempAllPOSPostingProfile.Insert();
            until POSPostingProfile.Next() = 0;
        if TempAllPOSPostingProfile.FindSet() then;

        TempAllEanBoxSetup.DeleteAll();
        if EanBoxSetup.FindSet() then
            repeat
                TempAllEanBoxSetup := EanBoxSetup;
                TempAllEanBoxSetup.Insert();
            until EanBoxSetup.Next() = 0;
        if TempAllEanBoxSetup.FindSet() then;

        TempAllPOSSalesWorkflowSet.DeleteAll();
        if POSSalesWorkflowSet.FindSet() then
            repeat
                TempAllPOSSalesWorkflowSet := POSSalesWorkflowSet;
                TempAllPOSSalesWorkflowSet.Insert();
            until POSSalesWorkflowSet.Next() = 0;
        if TempAllPOSSalesWorkflowSet.FindSet() then;

        TempAllGlobalPOSSalesSetup.DeleteAll();
        if GlobalPOSSalesSetup.FindSet() then
            repeat
                TempAllGlobalPOSSalesSetup := GlobalPOSSalesSetup;
                TempAllGlobalPOSSalesSetup.Insert();
            until GlobalPOSSalesSetup.Next() = 0;
        if TempAllGlobalPOSSalesSetup.FindSet() then;
    end;

    internal procedure CreateTempPOSUnits(ParamNoOfPOSUnits: integer; WantedStartingNo: Code[10]; SelectedPOSStore: Code[10]; var POSUnitTemp: Record "NPR POS Unit")
    var
        POSUnit: Record "NPR POS Unit";
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
        i: Integer;
        LastNoUsed: Code[10];
    begin
        Rec.Reset();

        LastNoUsed := WantedStartingNo;

        for i := 1 to ParamNoOfPOSUnits do begin
            Rec.Init();
            LastNoUsed := CheckIfNoAvailableInPOSUnit(POSUnit, LastNoUsed);
            LastNoUsed := CheckIfNoAvailableInPOSUnit(POSUnitTemp, LastNoUsed);
            Rec."No." := LastNoUsed;
            Rec.Insert();

            Rec."POS Store Code" := SelectedPOSStore;
            Rec.Modify();

            if i = 1 then
                HelperFunctions.FormatCode(LastNoUsed, true)
            else
                LastNoUsed := IncStr(LastNoUsed);
        end;
    end;

    local procedure CheckIfNoAvailableInPOSUnit(var POSUnit: Record "NPR POS Unit"; var WantedStartingNo: Code[10]) CalculatedNo: Code[10]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        if POSUnit.Get(WantedStartingNo) then begin
            HelperFunctions.FormatCode(WantedStartingNo, false);
            HelperFunctions.FormatCode(WantedStartingNo, true);
            CalculatedNo := CheckIfNoAvailableInPOSUnit(POSUnit, WantedStartingNo);
        end;
    end;

    internal procedure GetRec(var TempPOSUnit: Record "NPR POS Unit")
    begin
        Rec.Reset();

        TempPOSUnit.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempPOSUnit := Rec;
                TempPOSUnit."POS Store Code" := '';
                TempPOSUnit.Insert();

                TempPOSUnit."POS Store Code" := Rec."POS Store Code";
                TempPOSUnit.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure SetRec(var TempPOSUnit: Record "NPR POS Unit")
    begin
        Rec.Reset();

        Rec.DeleteAll();
        if TempPOSUnit.FindSet() then
            repeat
                if TempPOSUnit.Status <> TempPOSUnit.Status::INACTIVE then begin
                    Rec := TempPOSUnit;
                    Rec."POS Store Code" := '';
                    Rec.Insert();

                    Rec."POS Store Code" := TempPOSUnit."POS Store Code";
                    Rec.Modify();
                end;
            until TempPOSUnit.Next() = 0;
    end;

    internal procedure CopyRealAndTemp(var TempPOSUnit: Record "NPR POS Unit")
    var
        POSUnit: Record "NPR POS Unit";
    begin
        Rec.Reset();

        TempPOSUnit.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempPOSUnit := Rec;
                TempPOSUnit."POS Store Code" := '';
                TempPOSUnit.Insert();

                TempPOSUnit."POS Store Code" := Rec."POS Store Code";
                TempPOSUnit.Modify();
            until Rec.Next() = 0;

        if POSUnit.FindSet() then
            repeat
                TempPOSUnit := POSUnit;
                if not TempPOSUnit.Insert() then;
            until POSUnit.Next() = 0;

        Commit();
    end;

    internal procedure POSUnitsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreatePOSUnitData(var POSUnitToCreate: Record "NPR POS Unit")
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if POSUnitToCreate.FindSet() then
            repeat
                POSUnit := POSUnitToCreate;
                if not POSUnit.Insert() then
                    POSUnit.Modify();
            until POSUnitToCreate.Next() = 0;
    end;
}
