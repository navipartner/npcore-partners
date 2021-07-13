page 6014409 "NPR POS Turnover"
{
    PageType = Worksheet;

    UsageCategory = ReportsAndAnalysis;
    SourceTable = "NPR POS Turnover Calc. Buffer";
    Caption = 'POS Turnover Info';
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

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
                }
                field(POSStoreCodeFilter; POSStoreCodeFilter)
                {
                    Caption = 'POS Store Code';

                    TableRelation = "NPR POS Store";
                    Editable = POSStoreCodeEditable;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field(POSUnitNoFilter; POSUnitNoFilter)
                {
                    Caption = 'POS Unit No.';

                    Editable = POSUnitNoFilterEditable;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        POSUnit.Reset();
                        POSUnit.SetRange("POS Store Code", POSStoreCodeFilter);
                        if POSUnit.FindFirst() then;

                        if Page.RunModal(0, POSUnit) = Action::LookupOK then begin
                            POSUnitNoFilter := POSUnit."No.";
                        end
                    end;
                }
            }
            group(Turnover)
            {
                repeater(Control1)
                {
                    TreeInitialState = ExpandAll;
                    IndentationColumn = Rec.Indentation;
                    ShowAsTree = true;
                    field(Description; Rec.Description)
                    {

                        StyleExpr = RowStyle1;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("This Year"; Rec."This Year")
                    {

                        StyleExpr = RowStyle2;
                        Editable = false;
                        ToolTip = 'Specifies the value of the This Year field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Last Year"; Rec."Last Year")
                    {

                        StyleExpr = RowStyle2;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Last Year field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Difference; Rec.Difference)
                    {

                        StyleExpr = RowStyle2;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Difference field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Difference %"; Rec."Difference %")
                    {

                        StyleExpr = RowStyle2;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Difference % field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Recalculate)
            {

                Caption = 'Recalculate';
                Image = Recalculate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Recalculate action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.FillData(BaseCalculationDate, POSStore, POSUnit, Rec);
                    if Rec.FindFirst() then;
                end;
            }
        }
    }

    var
        RowStyle1, RowStyle2 : Text;
        POSStoreCodeFilter, POSUnitNoFilter : Text;
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        POSStoreCodeEditable: Boolean;
        POSUnitNoFilterEditable: Boolean;
        BaseCalculationDate: Date;

    trigger OnInit()
    var
        POSSession: Codeunit "NPR POS Session";
        POSSessionMgt: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        BaseCalculationDate := WorkDate();
        POSStoreCodeEditable := true;
        POSUnitNoFilterEditable := true;

        if POSSessionMgt.GetSession(POSSession, false) then begin
            POSSession.GetSetup(POSSetup);
            POSSetup.GetPOSStore(POSStore);
            POSSetup.GetPOSUnit(POSUnit);

            POSStoreCodeFilter := POSStore.Code;
            POSUnitNoFilter := POSUnit."No.";

            POSStoreCodeEditable := false;
            POSUnitNoFilterEditable := false;
        end;

        Rec.FillData(BaseCalculationDate, POSStore, POSUnit, Rec);
        if Rec.FindFirst() then;
    end;

    trigger OnAfterGetRecord()
    begin
        RowStyle1 := '';
        RowStyle2 := '';

        if Rec.Indentation = 0 then begin
            RowStyle1 := Rec."Row Style";
            RowStyle2 := Rec."Row Style";
        end;

        if Rec.Indentation = 1 then
            RowStyle1 := Rec."Row Style";
    end;
}
