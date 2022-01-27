codeunit 6014428 "NPR POS After Sale Execution"
{
    Access = Internal;
    trigger OnRun()
    begin
        case OnRunType of
            // If somebody accidentally (or even intentionall) calls this codeunit without defining what kind of
            // run type is needed, then codeunit simply exits
            OnRunType::Undefined:
                exit;
            OnRunType::RunAfterEndSale:
                begin
                    PosSaleCodeunit.InvokeOnFinishSaleWorkflow(Rec);
                    Commit();
                    PosSaleCodeunit.OnAfterEndSale(OnRunXRec);
                    Commit();
                end;
            OnRunType::OnFinishSale:
                begin
                    PosSaleCodeunit.OnFinishSale(OnRunPOSSalesWorkflowStep, Rec);
                    Commit();
                end;
        end;
    end;

    procedure RecSet(RecPar: Record "NPR POS Sale")
    begin
        Rec.Copy(RecPar);
    end;

    procedure PosSaleCodeunitSet(PosSalePar: Codeunit "NPR POS Sale")
    begin
        PosSaleCodeunit := PosSalePar;
    end;

    procedure OnRunXRecSet(XRecPar: Record "NPR POS Sale")
    begin
        OnRunXRec := XRecPar;
    end;

    procedure OnRunPOSSalesWorkflowStepSet(POSSalesWorkflowStepPar: Record "NPR POS Sales Workflow Step")
    begin
        OnRunPOSSalesWorkflowStep := POSSalesWorkflowStepPar;
    end;

    procedure OnRunTypeSet(OnRunTypePar: Enum "NPR POS Sale OnRunType")
    begin
        OnRunType := OnRunTypePar;
    end;

    var
        Rec: Record "NPR POS Sale";
        OnRunPOSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        OnRunXRec: Record "NPR POS Sale";
        PosSaleCodeunit: Codeunit "NPR POS Sale";
        OnRunType: Enum "NPR POS Sale OnRunType";
}
