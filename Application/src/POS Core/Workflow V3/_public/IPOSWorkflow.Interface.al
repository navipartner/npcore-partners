interface "NPR IPOS Workflow"
{
#if not BC17
    Access = Public;
#endif
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
}