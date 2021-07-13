page 6014684 "NPR POS Payment Bins Step"
{
    Caption = 'POS Payment Bins';
    PageType = ListPart;
    SourceTable = "NPR POS Payment Bin";
    SourceTableTemporary = true;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(SelectPOSUnit)
            {
                Caption = 'Select POS Unit';
                field(POSUnitCode; SelectedPOSUnit)
                {
                    ShowMandatory = true;
                    Caption = 'POS Unit Code';

                    Lookup = true;
                    ToolTip = 'Specifies the value of the POS Unit Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        NoOfPOSPaymentBinsToCreate := 0;
                        StartingNoPaymentBin := '';

                        if Page.RunModal(Page::"NPR POS Units Select", TempAllPOSUnit) = Action::LookupOK then begin
                            SelectedPOSUnit := TempAllPOSUnit."No.";
                            SelectedPOSStore := TempAllPOSUnit."POS Store Code";
                            CurrPage.Update(false);
                        end;

                        Rec.SetRange("Attached to POS Unit No.", SelectedPOSUnit);
                    end;
                }
            }
            group(Empty)
            {
                Caption = '';
                InstructionalText = ' ';
            }
            group(POSPaymentBinNoOfBins)
            {
                Caption = 'Payment Bins Information';
                field(NoOfPOSPaymentBins; NoOfPOSPaymentBinsToCreate)
                {
                    Caption = 'Number of payment bins to create';

                    ToolTip = 'Specifies the value of the Number of payment bins to create field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (StartingNoPaymentBin <> '') and (SelectedPOSUnit <> '') then begin
                            GetRec(TempPOSPaymentBin);

                            CreateTempPOSPaymentBins(NoOfPOSPaymentBinsToCreate, StartingNoPaymentBin, SelectedPOSStore, SelectedPOSUnit, TempPOSPaymentBin);

                            NoOfPOSPaymentBinsToCreate := 0;
                            StartingNoPaymentBin := '';
                        end;
                        CurrPage.Update(false);
                        Rec.SetRange("Attached to POS Unit No.", SelectedPOSUnit);
                    end;
                }
            }
            group(StartingNoGroup)
            {
                Caption = '';
                InstructionalText = 'In case that the selected Starting No. is taken, the first available No. will be used. That will be applied to all POS Payment Bins.';
            }
            group(POSPaymentBinSteartingNo)
            {
                Caption = '';
                field(StartingNoPaymentBin; StartingNoPaymentBin)
                {
                    Caption = 'Starting No.';

                    ToolTip = 'Specifies the value of the Starting No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (NoOfPOSPaymentBinsToCreate <> 0) and (SelectedPOSUnit <> '') then begin
                            GetRec(TempPOSPaymentBin);
                            CreateTempPOSPaymentBins(NoOfPOSPaymentBinsToCreate, StartingNoPaymentBin, SelectedPOSStore, SelectedPOSUnit, TempPOSPaymentBin);

                            NoOfPOSPaymentBinsToCreate := 0;
                            StartingNoPaymentBin := '';
                        end;
                        CurrPage.Update(false);
                        Rec.SetRange("Attached to POS Unit No.", SelectedPOSUnit);
                    end;
                }
            }
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Attached to POS Unit No."; Rec."Attached to POS Unit No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Attached to POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Eject Method"; Rec."Eject Method")
                {

                    ToolTip = 'Specifies the value of the Eject Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Bin Type"; Rec."Bin Type")
                {

                    ToolTip = 'Specifies the value of the Bin Type field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        TempAllPOSUnit: Record "NPR POS Unit" temporary;
        TempPOSPaymentBin: Record "NPR POS Payment Bin" temporary;
        SelectedPOSStore: Code[10];
        SelectedPOSUnit: Code[10];
        StartingNoPaymentBin: Code[10];
        NoOfPOSPaymentBinsToCreate: Integer;

    procedure SetGlobals(var POSUnitAll: Record "NPR POS Unit")
    begin
        TempAllPOSUnit.DeleteAll();
        if POSUnitAll.FindSet() then
            repeat
                TempAllPOSUnit := POSUnitAll;

                TempAllPOSUnit."POS Store Code" := '';
                TempAllPOSUnit.Insert();

                TempAllPOSUnit."POS Store Code" := POSUnitAll."POS Store Code";
                TempAllPOSUnit.Modify();
            until POSUnitAll.Next() = 0;

        if TempAllPOSUnit.FindSet() then;
    end;

    procedure CreateTempPOSPaymentBins(NoOfPOSPaymentBins: integer; WantedStartingNo: Code[10]; SelectedPOSStore: Code[10]; SelectedPOSPaymentBin: Code[10]; var POSPaymentBinTemp: Record "NPR POS Payment Bin")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
        i: Integer;
        LastNoUsed: Code[10];
    begin
        Rec.Reset();

        LastNoUsed := WantedStartingNo;

        for i := 1 to NoOfPOSPaymentBins do begin
            Rec.Init();
            LastNoUsed := CheckIfNoAvailableInPOSPaymentBin(POSPaymentBin, LastNoUsed);
            LastNoUsed := CheckIfNoAvailableInPOSPaymentBin(POSPaymentBinTemp, LastNoUsed);
            Rec."No." := LastNoUsed;
            Rec.Insert();

            Rec."POS Store Code" := SelectedPOSStore;
            Rec."Attached to POS Unit No." := SelectedPOSPaymentBin;
            Rec.Modify();

            if i = 1 then
                HelperFunctions.FormatCode(LastNoUsed, true)
            else
                LastNoUsed := IncStr(LastNoUsed);
        end;
    end;

    local procedure CheckIfNoAvailableInPOSPaymentBin(var POSPaymentBin: Record "NPR POS Payment Bin"; var WantedStartingNo: Code[10]) CalculatedNo: Code[10]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        if POSPaymentBin.Get(WantedStartingNo) then begin
            HelperFunctions.FormatCode(WantedStartingNo, true);
            CalculatedNo := CheckIfNoAvailableInPOSPaymentBin(POSPaymentBin, WantedStartingNo);
        end;
    end;

    procedure GetRec(var TempPOSPaymentBin: Record "NPR POS Payment Bin")
    begin
        Rec.Reset();

        TempPOSPaymentBin.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempPOSPaymentBin := Rec;
                TempPOSPaymentBin.Insert();
            until Rec.Next() = 0;
    end;

    procedure SetRec(var TempPOSPaymentBin: Record "NPR POS Payment Bin")
    begin
        Rec.Reset();

        Rec.Copy(TempPOSPaymentBin, true);
    end;

    procedure CopyRealAndTemp(var TempPOSPaymentBin: Record "NPR POS Payment Bin")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
    begin
        Rec.Reset();

        TempPOSPaymentBin.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempPOSPaymentBin := Rec;
                TempPOSPaymentBin.Insert();
            until Rec.Next() = 0;

        if POSPaymentBin.FindSet() then
            repeat
                TempPOSPaymentBin := POSPaymentBin;
                TempPOSPaymentBin.Insert();
            until POSPaymentBin.Next() = 0;
    end;

    procedure POSPaymentBinsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CreatePOSPaymentBinData(var POSPaymentBinToCreate: Record "NPR POS Payment Bin")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
    begin
        if POSPaymentBinToCreate.FindSet() then
            repeat
                POSPaymentBin := POSPaymentBinToCreate;
                if not POSPaymentBin.Insert() then
                    POSPaymentBin.Modify();
            until POSPaymentBinToCreate.Next() = 0;
    end;
}