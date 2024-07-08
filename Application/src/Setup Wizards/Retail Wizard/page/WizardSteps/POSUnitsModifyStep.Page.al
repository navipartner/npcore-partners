page 6150848 "NPR POS Units Modify Step"
{
    Caption = 'POS Units';
    Extensible = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR POS Unit";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines name of POS Unit';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines in which status POS is: 1. Open POS is active in the moment, 2. Closed POS is closed in the moment, end of day is done, 3. End of Day POS is in the process of end of day in the moment';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines to which store is assigned a POS unit';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Page.RunModal(Page::"NPR POS Store List", TempPOSStores_) = Action::LookupOK then begin
                            Rec."POS Store Code" := TempPOSStores_.Code;
                        end;
                    end;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Dimension value of Global dimension 1 assigned to POS Unit';

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
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Dimension value of Global dimension 2 assigned to POS Unit';

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
                field("POS Sales Workflow Set"; Rec."POS Sales Workflow Set")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines Scenarios Profile attached to Unit. Depending on scenario profile will initiate defined actions in POS';
                    Visible = false;
                }
                field("POS Type"; Rec."POS Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies POS Type: 1. Full/Fixed normal cash register, 2. Unattended used for Self-service, 3. mPOS, 4. External';
                }
                field("POS Payment Bin"; Rec."Default POS Payment Bin")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Defines Payment Bin attached to POS Unit';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Page.RunModal(Page::"NPR POS Payment Bins", TempPOSPaymentBin_) = Action::LookupOK then begin
                            Rec."Default POS Payment Bin" := TempPOSPaymentBin_."No.";
                        end;
                    end;
                }
                field("POS Audit Profile"; Rec."POS Audit Profile")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Audit Profile field';
                }
                field("POS View Profile"; Rec."POS View Profile")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS View Profile field';
                }
                field("POS End of Day Profile"; Rec."POS End of Day Profile")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS End of Day Profile field.';
                }
                field("Ean Box Sales Setup"; Rec."Ean Box Sales Setup")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Ean Box Setup that will be used on Sales screen.';
                }
            }
        }
    }



    var
        GLSetup: Record "General Ledger Setup";
        TempPOSPaymentBin_: Record "NPR POS Payment Bin" temporary;
        TempPOSStores_: Record "NPR POS Store" temporary;

    internal procedure CopyAllPOSStores(var TempPOSStores: Record "NPR POS Store")
    begin
        if TempPOSStores.FindSet() then
            repeat
                TempPOSStores_ := TempPOSStores;
                if TempPOSStores_.Insert() then;
            until TempPOSStores.Next() = 0;
    end;

    internal procedure CopyTemp(var TempPOSUnit: Record "NPR POS Unit")
    begin
        if TempPOSUnit.FindSet() then
            repeat
                Rec := TempPOSUnit;
                if Rec.Insert() then;
            until TempPOSUnit.Next() = 0;
    end;

    internal procedure CreatePOSUnitData()
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSUnit: Record "NPR POS Unit";
    begin
        if Rec.FindSet() then
            repeat
                POSUnit := Rec;
                if not POSUnit.Insert() then
                    POSUnit.Modify();

                CreatePOSPaymentBin(POSPaymentBin, Rec);
                CreatePOSUnitToBinRelation(POSPaymentBin, Rec);
                CreateDefaultDimensions(POSUnit);
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempPOSPaymentBin(var POSPaymentBin: Record "NPR POS Payment Bin")
    begin
        if POSPaymentBin.FindSet() then
            repeat
                TempPOSPaymentBin_ := POSPaymentBin;
                if not TempPOSPaymentBin_.Insert() then
                    TempPOSPaymentBin_.Modify();

            until POSPaymentBin.Next() = 0;
    end;

    internal procedure DimensionsToCreate(): Boolean
    var
        TempPOSUnit: Record "NPR POS Unit" temporary;
        GlobalDimension1Populated: Boolean;
        GlobalDimension2Populated: Boolean;
    begin
        if Rec.IsEmpty() then
            exit(false);

        TempPOSUnit.Copy(Rec, true);
        TempPOSUnit.SetFilter("Global Dimension 1 Code", '<>%1', '');

        GlobalDimension1Populated := not TempPOSUnit.IsEmpty();

        TempPOSUnit.Reset();
        TempPOSUnit.SetFilter("Global Dimension 2 Code", '<>%1', '');
        GlobalDimension2Populated := not TempPOSUnit.IsEmpty();

        exit(GlobalDimension1Populated or GlobalDimension2Populated);
    end;

    local procedure CreatePOSPaymentBin(var POSPaymentBin: Record "NPR POS Payment Bin"; POSUnit: Record "NPR POS Unit")
    var
        DescriptionLbl: Label 'Cash Drawer %1';
    begin
        POSPaymentBin.Init();
        POSPaymentBin."No." := POSUnit."No.";
        POSPaymentBin.Description := StrSubstNo(DescriptionLbl, POSUnit."No.");
        POSPaymentBin."POS Store Code" := POSUnit."POS Store Code";
        POSPaymentBin."Attached to POS Unit No." := POSUnit."No.";
        POSPaymentBin."Eject Method" := 'PRINTER';
        POSPaymentBin."Bin Type" := POSPaymentBin."Bin Type"::CASH_DRAWER;
        POSPaymentBin.Status := POSPaymentBin.Status::CLOSED;
        if not POSPaymentBin.Insert() then
            POSPaymentBin.Modify();
    end;

    local procedure CreatePOSUnitToBinRelation(POSPaymentBin: Record "NPR POS Payment Bin"; POSUnit: Record "NPR POS Unit")
    var
        POSUnittoBinRelation: Record "NPR POS Unit to Bin Relation";
    begin
        POSUnittoBinRelation.Init();
        POSUnittoBinRelation."POS Unit No." := POSUnit."No.";
        POSUnittoBinRelation."POS Payment Bin No." := POSPaymentBin."No.";
        POSUnittoBinRelation.Insert();
    end;

    local procedure CreateDefaultDimensions(POSUnit: Record "NPR POS Unit")
    begin
        GLSetup.Get();

        CreateDefaultDimension(POSUnit, POSUnit."Global Dimension 1 Code", GLSetup."Global Dimension 1 Code");
        CreateDefaultDimension(POSUnit, POSUnit."Global Dimension 2 Code", GLSetup."Global Dimension 2 Code");
    end;

    local procedure CreateDefaultDimension(POSUnit: Record "NPR POS Unit"; DimensionValueCode: Code[20]; DimensionCode: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        if DimensionValueCode = '' then
            exit;

        if DimensionCode = '' then
            exit;

        if DefaultDimension.Get(Database::"NPR POS Unit", POSUnit."No.", DimensionCode) then
            exit;

        DefaultDimension.Init();
        DefaultDimension."Table ID" := Database::"NPR POS Unit";
        DefaultDimension."No." := POSUnit."No.";
        DefaultDimension."Dimension Code" := DimensionCode;
        DefaultDimension."Dimension Value Code" := DimensionValueCode;
        DefaultDimension.Insert();
    end;
}