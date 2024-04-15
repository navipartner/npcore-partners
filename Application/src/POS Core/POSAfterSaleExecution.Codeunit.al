codeunit 6014428 "NPR POS After Sale Execution"
{
    Access = Internal;
    trigger OnRun()
    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        case OnRunType of
            // If somebody accidentally (or even intentionall) calls this codeunit without defining what kind of
            // run type is needed, then codeunit simply exits
            OnRunType::Undefined:
                exit;
            OnRunType::RunAfterEndSale:
                begin
                    PosSaleCodeunit.InvokeOnFinishSaleWorkflow(Rec);
                    if FeatureFlagsManagement.IsEnabled('posLifeCycleEventsWorkflowsEnabled_v2') then
                        PosSaleCodeunit.InvokeOnFinishSaleWorkflows(Rec);
                    Commit();
                    PosSaleCodeunit.OnAfterEndSale(OnRunXRec);
                    Commit();
                end;
            OnRunType::OnFinishSale:
                begin
                    PosSaleCodeunit.OnBeforeFinishSale(Rec);
                    Commit();
                    if UseNewExecutionOrderImplementation then
                        CODEUNIT.Run(OnRunExecutionOrderOnSale."Codeunit ID", Rec)
                    else
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
        UseNewExecutionOrderImplementation := false;
    end;

    procedure OnRunTypeSet(OnRunTypePar: Enum "NPR POS Sale OnRunType")
    begin
        OnRunType := OnRunTypePar;
    end;

    procedure OnRunPOSSalesWorkflow(TempExecutionOrderOnSale: Record "NPR Execution Order On Sale")
    begin
        OnRunExecutionOrderOnSale := TempExecutionOrderOnSale;
        UseNewExecutionOrderImplementation := true;
    end;

    var
        Rec: Record "NPR POS Sale";
        OnRunPOSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        OnRunExecutionOrderOnSale: Record "NPR Execution Order On Sale";
        //This variable has to be removed when pos scenarios are fully removed.
        UseNewExecutionOrderImplementation: Boolean;

        OnRunXRec: Record "NPR POS Sale";
        PosSaleCodeunit: Codeunit "NPR POS Sale";
        OnRunType: Enum "NPR POS Sale OnRunType";
}
