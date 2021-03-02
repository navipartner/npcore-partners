codeunit 6014428 "NPR POS After Sale Execution"
{
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
                    Commit;
                    PosSaleCodeunit.OnAfterEndSale(OnRunXRec);
                    Commit;
                end;
            OnRunType::OnFinishSale:
                begin
                    PosSaleCodeunit.OnFinishSale(OnRunPOSSalesWorkflowStep, Rec);
                    Commit;
                end;
        end;
    end;

    procedure RecSet(RecPar: Record "NPR Sale POS")
    begin
        Rec.Copy(RecPar);
    end;

    procedure PosSaleCodeunitSet(PosSalePar: Codeunit "NPR POS Sale")
    begin
        PosSaleCodeunit := PosSalePar;
    end;

    procedure OnRunXRecSet(XRecPar: Record "NPR Sale POS")
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
        Rec: Record "NPR Sale POS";
        OnRunPOSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        OnRunXRec: Record "NPR Sale POS";
        PosSaleCodeunit: Codeunit "NPR POS Sale";
        OnRunType: Enum "NPR POS Sale OnRunType";
}