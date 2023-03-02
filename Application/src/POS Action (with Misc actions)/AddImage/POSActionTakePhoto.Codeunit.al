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
        AddPhotoTo: Integer;
    begin
        Context.GetIntegerParameter('AddPhotoToSelection', AddPhotoTo);

        if AddPhotoTo = 0 then
            TakePhoto(Sale) //Current POS Sale
        else
            AddImageOnPosEntry(Context, Setup, AddPhotoTo);
    end;

    local procedure TakePhoto(POSSaleCU: Codeunit "NPR POS Sale"): JsonObject
    var
        POSSaleMediaInfo: Record "NPR POS Sale Media Info";
        POSSale: Record "NPR POS Sale";
    begin
        POSSaleCU.GetCurrentSale(POSSale);
        POSSaleMediaInfo.CreateNewEntry(POSSale, 1);
    end;

    local procedure AddImageOnPosEntry(Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup"; AddPhotoTo: Option ,LastPosEntry,SelectPosEntry,PosEntryByDocumentNo)
    var
        POSUnit: Record "NPR POS Unit";
        POSEntry: Record "NPR POS Entry";
        POSEntryMediaInfo: Record "NPR POS Entry Media Info";
        DocumentNo: Text;
        InvalidDocumentNo: Label 'Entered Document No. %1 is not valid. Please enter valid value.', Comment = '%1-document no.';
    begin
        case AddPhotoTo of
            AddPhotoTo::LastPosEntry, AddPhotoTo::SelectPosEntry:
                begin
                    Setup.GetPOSUnit(POSUnit);
                    if POSUnit."No." = '' then
                        exit;

                    FilterPosEntries(POSUnit, POSEntry);

                    if AddPhotoTo = AddPhotoTo::LastPosEntry then begin
                        if not POSEntry.FindLast() then
                            exit;
                    end
                    else begin
                        if not SelectPOSEntry(POSEntry) then
                            exit;
                    end;
                end;

            AddPhotoTo::PosEntryByDocumentNo:
                begin
                    DocumentNo := Context.GetString('PosEntry_DocumentNo');
                    if (DocumentNo = '') or (StrLen(DocumentNo) > MaxStrLen(POSEntry."Document No.")) then
                        Error(InvalidDocumentNo, DocumentNo);
                    POSEntry.SetCurrentKey("Document No.");
                    POSEntry.SetRange("Document No.", DocumentNo);
                    POSEntry.FindFirst();
                end;
        end;

        POSEntryMediaInfo.CreateNewEntry(POSEntry, 1, false);
    end;

    local procedure SelectPOSEntry(var POSEntry: Record "NPR POS Entry"): Boolean
    var
        EntryCount: Integer;
    begin
        EntryCount := POSEntry.Count;

        case EntryCount of
            0:
                exit(false);
            1:
                begin
                    POSEntry.FindLast();
                    exit(true);
                end;
            else begin
                POSEntry.Ascending(false);
                if POSEntry.FindFirst() then;
                if PAGE.RunModal(0, POSEntry) <> ACTION::LookupOK then
                    exit(false);

                exit(true);
            end;
        end;
    end;

    local procedure FilterPosEntries(POSUnit: Record "NPR POS Unit"; var POSEntry: Record "NPR POS Entry")
    begin
        POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
        POSEntry.SetRange("POS Store Code", POSUnit."POS Store Code");
        POSEntry.SetRange("POS Unit No.", POSUnit."No.");
        POSEntry.SetRange("System Entry", false);
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionTakePhoto.js###        
'let main=async({workflow:t,context:c,popup:o,parameters:e,captions:n})=>{if(e.AddPhotoToSelection==3){if(t.context.PosEntry_DocumentNo=await o.input({title:n.SelectPosEntryByDocumentNo,caption:n.DocumentNo}),t.context.PosEntry_DocumentNo===null)return;if(t.context.PosEntry_DocumentNo==""||t.context.PosEntry_DocumentNo.length>20){o.error(n.InvalidDocumentNo);return}}return await t.respond()};'
        );
    end;
}
