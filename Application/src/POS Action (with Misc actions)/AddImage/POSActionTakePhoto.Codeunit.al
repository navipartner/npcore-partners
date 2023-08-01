codeunit 6059840 "NPR POS Action Take Photo" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a function for adding image using camera to a active POS Sale.';
        AddPhotoToSelectionLbl: Label 'AddPhotoToSelection', Locked = true;
        AddPhotoToSelectionCaptionLbl: Label 'Add Photo To Selection', Locked = true;
        AddPhotoToOptionLbl: Label 'CurrentPosSale,LastPosEntry,SelectPosEntry,PosEntryByDocumentNo', Locked = true;
        AddPhotoToOptionCaptionLbl: Label 'Current POS Sale,Last POS Entry,Select POS Entry,POS Entry By DocumentNo';
        SelectPosEntryByDocumentNoLbl: Label 'Select Pos Entry By DocumentNo';
        InvalidDocumentNoLbl: Label 'Entered Document No. is not valid. Please enter valid value.';
        DocumentNoLbl: Label 'Document No:';

    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(
            AddPhotoToSelectionLbl,
            AddPhotoToOptionLbl,
#pragma warning disable AA0139
            SelectStr(1, AddPhotoToOptionLbl),
#pragma warning restore 
            AddPhotoToSelectionLbl,
            AddPhotoToSelectionCaptionLbl,
            AddPhotoToOptionCaptionLbl);
        WorkflowConfig.AddLabel('SelectPosEntryByDocumentNo', SelectPosEntryByDocumentNoLbl);
        WorkflowConfig.AddLabel('InvalidDocumentNo', InvalidDocumentNoLbl);
        WorkflowConfig.AddLabel('DocumentNo', DocumentNoLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogic: Codeunit "NPR POS Action Take Photo B";
        AddPhotoTo: Integer;
        DocumentNo: Text;
    begin
        Context.GetIntegerParameter('AddPhotoToSelection', AddPhotoTo);
        DocumentNo := Context.GetString('PosEntry_DocumentNo');

        if AddPhotoTo = 0 then
            BusinessLogic.TakePhoto(Sale) //Current POS Sale
        else
            BusinessLogic.AddImageOnPosEntry(DocumentNo, Setup, AddPhotoTo);
    end;



    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionTakePhoto.js###        
'let main=async({workflow:t,context:c,popup:o,parameters:e,captions:n})=>{if(e.AddPhotoToSelection==3){if(t.context.PosEntry_DocumentNo=await o.input({title:n.SelectPosEntryByDocumentNo,caption:n.DocumentNo}),t.context.PosEntry_DocumentNo===null)return;if(t.context.PosEntry_DocumentNo==""||t.context.PosEntry_DocumentNo.length>20){o.error(n.InvalidDocumentNo);return}}return await t.respond()};'
        );
    end;
}
