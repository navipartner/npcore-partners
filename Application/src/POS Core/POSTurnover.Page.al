page 6014409 "NPR POS Turnover"
{
    Extensible = False;
    PageType = List;
    SourceTable = "NPR POS Turnover Calc. Buffer";
    Caption = 'POS Turnover Info';
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                field(BaseCalculationDate; BaseCalculationDate)
                {
                    Caption = 'Calculation Date';
                    ToolTip = 'Specifies the value of the Calculation Date field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        POSStatsMgt.FillTurnoverData(Rec, BaseCalculationDate, POSStoreCodeFilter, POSUnitNoFilter);
                        CurrPage.Update(false);
                    end;
                }
                field(POSStoreCodeFilter; POSStoreCodeFilter)
                {
                    Caption = 'POS Store Code';
                    TableRelation = "NPR POS Store";
                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SelectPOSUnitNo();
                    end;
                }
                field(POSUnitNoFilter; POSUnitNoFilter)
                {
                    Caption = 'POS Unit No.';
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        SelectPOSUnitNo();
                    end;
                }
            }
            group(Turnover)
            {
                Caption = '';

                repeater(Control1)
                {
                    field(Description; Rec.Description)
                    {

                        StyleExpr = Rec."Row Style";
                        Editable = false;
                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("This Year"; Rec."This Year")
                    {

                        StyleExpr = Rec."Row Style";
                        Editable = false;
                        ToolTip = 'Specifies the value of the This Year field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Last Year"; Rec."Last Year")
                    {

                        StyleExpr = Rec."Row Style";
                        Editable = false;
                        ToolTip = 'Specifies the value of the Last Year field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Difference %"; Rec."Difference %")
                    {
                        StyleExpr = Rec."Row Style";
                        Editable = false;
                        ToolTip = 'Specifies the value of the Difference % field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        POSStore: Record "NPR POS Store";
    begin
        BaseCalculationDate := WorkDate();
        POSSession.GetSetup(POSSetup);

        POSSetup.GetPOSStore(POSStore);
        POSStoreCodeFilter := POSStore.Code;

        POSUnitNoFilter := POSSetup.GetPOSUnitNo();

        Rec.FindFirst();
    end;

    local procedure SelectPOSUnitNo()
    var
        POSUnit: Record "NPR POS Unit";
        POSStoreWithoutPOSUnitsLbl: Label 'POS Store %1 does not have POS Units.';
    begin
        POSUnit.Reset();
        POSUnit.FilterGroup(2);
        POSUnit.SetRange("POS Store Code", POSStoreCodeFilter);
        POSUnit.FilterGroup(0);

        if POSUnit.IsEmpty() then begin
            Message(POSStoreWithoutPOSUnitsLbl, POSStoreCodeFilter);
            exit;
        end;

        if Page.RunModal(0, POSUnit) = Action::LookupOK then begin
            POSUnitNoFilter := POSUnit."No.";
            POSStatsMgt.FillTurnoverData(Rec, BaseCalculationDate, POSStoreCodeFilter, POSUnitNoFilter);
            CurrPage.Update(false);
        end
    end;

    var
        POSStoreCodeFilter: Code[10];
        POSUnitNoFilter: Code[10];
        BaseCalculationDate: Date;
        POSStatsMgt: Codeunit "NPR POS Statistics Mgt.";
}
