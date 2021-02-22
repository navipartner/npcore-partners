page 6014409 "NPR POS Turnover"
{
    PageType = ListPlus;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "NPR POS Turnover Calc. Buffer";
    Caption = 'POS Turnover Info';
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                field(POSStoreCodeFilter; POSStoreCodeFilter)
                {
                    Caption = 'POS Store Code';
                    ApplicationArea = All;
                    TableRelation = "NPR POS Store";
                    Editable = POSStoreCodeEditable;

                    trigger OnValidate()
                    begin
                        POSStore.SetRange(Code, POSStoreCodeFilter);
                        POSUnit.SetRange("No.", POSUnitNoFilter);
                        FillData(POSStore, POSUnit, Rec);
                    end;
                }
                field(POSUnitNoFilter; POSUnitNoFilter)
                {
                    Caption = 'POS Unit No.';
                    ApplicationArea = All;
                    Editable = POSUnitNoFilterEditable;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        POSUnit.Reset();
                        POSUnit.SetRange("POS Store Code", POSStoreCodeFilter);
                        if POSUnit.FindFirst() then;

                        if Page.RunModal(0, POSUnit) = Action::LookupOK then begin
                            POSUnitNoFilter := POSUnit."No.";
                        end
                    end;

                    trigger OnValidate()
                    begin
                        POSStore.SetRange(Code, POSStoreCodeFilter);
                        POSUnit.SetRange("No.", POSUnitNoFilter);
                        FillData(POSStore, POSUnit, Rec);
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
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                        StyleExpr = RowStyle1;
                        Editable = false;
                    }
                    field("This Year"; "This Year")
                    {
                        ApplicationArea = All;
                        StyleExpr = RowStyle2;
                        Editable = false;
                    }
                    field("Last Year"; "Last Year")
                    {
                        ApplicationArea = All;
                        StyleExpr = RowStyle2;
                        Editable = false;
                    }
                    field(Difference; Difference)
                    {
                        ApplicationArea = All;
                        StyleExpr = RowStyle2;
                        Editable = false;
                    }
                    field("Difference %"; "Difference %")
                    {
                        ApplicationArea = All;
                        StyleExpr = RowStyle2;
                        Editable = false;
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
                ApplicationArea = All;
                Caption = 'Recalculate';
                Image = Recalculate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.FillData(POSStore, POSUnit, Rec);
                    if FindFirst() then;
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

    trigger OnInit()
    var
        POSSession: Codeunit "NPR POS Session";
        POSSessionMgt: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
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

        Rec.FillData(POSStore, POSUnit, Rec);
        if FindFirst() then;
    end;

    trigger OnAfterGetRecord()
    begin
        RowStyle1 := '';
        RowStyle2 := '';

        if Indentation = 0 then begin
            RowStyle1 := "Row Style";
            RowStyle2 := "Row Style";
        end;

        if Indentation = 1 then
            RowStyle1 := "Row Style";
    end;
}