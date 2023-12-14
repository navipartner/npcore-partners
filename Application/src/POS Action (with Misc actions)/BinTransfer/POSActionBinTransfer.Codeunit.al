codeunit 6150851 "NPR POS Action: Bin Transfer" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
        PrintTransferNameLbl: Label 'PrintTransfer', Locked = true;
        TransferDirectionParamName: Label 'TransferDirection', Locked = true;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Transfer funds in or out of POS bin.';
        BinSelectionLbl: Label 'SourceBinSelection', Locked = true;
        BinOptionsLbl: Label 'PosUnitDefaultBin,UserSelection,FixedParameter', Locked = true;
        BinSelection_CptLbl: Label 'Bin Selection';
        BinSelection_CptDescLbl: Label 'Specifies how the POS unit bin will be selected for transfer transactions. This bin will be the destination for transfer INs, or the source for transfer OUTs.';
        BinOptions_CptLbl: Label 'POS Unit Default Bin,User Selection (Ask),Fixed Bin';
        Bin_NameLbl: Label 'SourceBin';
        Bin_CptLbl: Label 'Fixed Bin';
        Bin_CptDescLbl: Label 'Specifies the pre-defined POS unit bin for transfer transactions. This bin will be the destination for transfer INs, or the source for transfer OUTs. The parameter is only used when "Bin Selection" is set to "Fixed Bin".';
        PrintTransferCaptionNameLbl: Label 'Print Transfer';
        PrintTransferCaptionDescriptionLbl: Label 'Print template from Report Selection - Retail, after transferring out content from bin. Template need to be built on top of "Workshift Checkpoint" table.';
        TransferDirectionCaption: Label 'Transfer Direction';
        TransferDirectionDescription: Label 'Bin transfer direction (In our Out of selected bin)';
        TransferDirectionOption: Label ',TransferOut,TransferIn', Locked = true;
        TransferDirectionOptionCaption: Label ',Transfer Out,Transfer In';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(
            BinSelectionLbl,
            BinOptionsLbl,
#pragma warning disable AA0139
            SelectStr(1, BinOptionsLbl),
#pragma warning restore 
            BinSelection_CptLbl,
            BinSelection_CptDescLbl,
            BinOptions_CptLbl);
        WorkflowConfig.AddBooleanParameter(PrintTransferNameLbl, false, PrintTransferCaptionNameLbl, PrintTransferCaptionDescriptionLbl);
        WorkflowConfig.AddTextParameter(Bin_NameLbl, '', Bin_CptLbl, Bin_CptDescLbl);
        WorkflowConfig.AddOptionParameter(TransferDirectionParamName, TransferDirectionOption, '', TransferDirectionCaption, TransferDirectionDescription, TransferDirectionOptionCaption);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'PrepareWorkflow':
                FrontEnd.WorkflowResponse(PrepareWorkflow(Context, Sale, Setup));
            'RunLegacyAction':
                RunLegacyAction(Context, Sale, Setup);
            'ProcessBinTranser':
                FrontEnd.WorkflowResponse(ProcessBinTransfer(Context, Sale));
        end;
    end;

    local procedure PrepareWorkflow(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup") Response: JsonObject
    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        BinNo: Code[10];
        PosUnitNo: Code[10];
        TransferDirection: Option "",TransferOut,TransferIn;
        LegacyAction: Boolean;
    begin
        SelectPosUnitBin(Context, Setup, PosUnitNo, BinNo);
        Context.SetContext('PosUnitNo', PosUnitNo);
        Context.SetContext('PosUnitBinNo', BinNo);

        LegacyAction := not FeatureFlagsManagement.IsEnabled(POSActionBinTransferB.NewBinTransferFeatureFlag());
        Response.Add('legacyAction', LegacyAction);
        if LegacyAction then
            exit;
        TransferDirection := Context.GetIntegerParameter(TransferDirectionParamName);
        Response.Add('binTransferContextData', POSActionBinTransferB.GetBinTransferContextData(PosUnitNo, BinNo, TransferDirection));
        Response.Add('postWorkflows', AddPostWorkflowsToRun(Context, Sale));
    end;

    local procedure ProcessBinTransfer(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale") Response: JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        ReturnedData: JsonToken;
        BinNo: Code[10];
        PosUnitNo: Code[10];
        CheckpointEntryNo: Integer;
        PrintTransfer: Boolean;
        Success: Boolean;
    begin
        ReturnedData := Context.GetJToken('returnedData');
#pragma warning disable AA0139
        PosUnitNo := Context.GetString('PosUnitNo');
        BinNo := Context.GetString('PosUnitBinNo');
#pragma warning restore AA0139
        if Context.GetBooleanParameter(PrintTransferNameLbl, PrintTransfer) then;

        POSSale.GetCurrentSale(SalePOS);
        Success := POSActionBinTransferB.ProcessBinTransfer(ReturnedData, SalePOS, PosUnitNo, BinNo, PrintTransfer, CheckpointEntryNo);
        Response.Add('success', Success);
        Response.Add('checkpointEntryNo', CheckpointEntryNo);
        if Success then
            POSSession.ChangeViewLogin();
    end;

    [Obsolete('Part of legacy action codebase. Can be deleted once the legacy action is not used anymore.', 'NPR28.0')]
    local procedure RunLegacyAction(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup")
    var
        TransferDirection: Option "",TransferOut,TransferIn;
    begin
        TransferDirection := Context.GetIntegerParameter(TransferDirectionParamName);
        case TransferDirection of
            TransferDirection::TransferIn:
                TransferContentsInToBin(Setup);
            TransferDirection::TransferOut:
                TransferContentsOutFromBin(Context, Sale);
        end;
    end;

    [Obsolete('Part of legacy action codebase. Can be deleted once the legacy action is not used anymore.', 'NPR28.0')]
    local procedure TransferContentsOutFromBin(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale")
    var
        CheckpointEntryNo: Integer;
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        FromBinNo: Code[10];
        POSSession: Codeunit "NPR POS Session";
        PrintTransfer: Boolean;
        PosUnit: Record "NPR POS Unit";
    begin
        FromBinNo := CopyStr(Context.GetString('PosUnitBinNo'), 1, MaxStrLen(FromBinNo));
        POSActionBinTransferB.GetPosUnitFromBin(FromBinNo, PosUnit);
        CheckpointEntryNo := POSWorkshiftCheckpoint.CreateEndWorkshiftCheckpoint_POSEntry(PosUnit."POS Store Code", PosUnit."No.", PosUnit.Status);

        POSActionBinTransferB.TransferContentsToBin(POSSession, FromBinNo, CheckpointEntryNo);
        if Context.GetBooleanParameter(PrintTransferNameLbl, PrintTransfer) and PrintTransfer then
            POSActionBinTransferB.PrintBinTransfer(CheckpointEntryNo);
    end;

    local procedure SelectPosUnitBin(Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup"; var PosUnitNo: Code[10]; var BinNo: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
        SourceBinSelection: Option PosUnitDefaultBin,UserSelection,FixedParameter;
    begin
        SourceBinSelection := Context.GetIntegerParameter('SourceBinSelection');
        if SourceBinSelection in [SourceBinSelection::PosUnitDefaultBin, SourceBinSelection::UserSelection] then
            Setup.GetPOSUnit(POSUnit);
        case SourceBinSelection of
            SourceBinSelection::UserSelection:
                BinNo := POSActionBinTransferB.UserSelectBin(POSUnit);
            SourceBinSelection::FixedParameter:
                begin
                    BinNo := GetFixedBin(Context);
                    POSActionBinTransferB.GetPosUnitFromBin(BinNo, PosUnit);
                end;
            else
                BinNo := POSActionBinTransferB.GetDefaultUnitBin(POSUnit);
        end;
        PosUnitNo := POSUnit."No.";
    end;

    [Obsolete('Part of legacy action codebase. Can be deleted once the legacy action is not used anymore.', 'NPR28.0')]
    local procedure TransferContentsInToBin(PosSetup: Codeunit "NPR POS Setup"): JsonObject
    var
        BinTransferJournalPage: Page "NPR BinTransferJournalPos";
        BinTransferJournal: Record "NPR BinTransferJournal";
    begin
        BinTransferJournal.SetFilter(ReceiveAtPosUnitCode, '=%1', PosSetup.GetPOSUnitNo());
        BinTransferJournal.SetFilter(Status, '=%1', BinTransferJournal.Status::RELEASED);
        BinTransferJournalPage.SetTableView(BinTransferJournal);
        BinTransferJournalPage.Run();
    end;

    local procedure GetFixedBin(Context: Codeunit "NPR POS JSON Helper"): Code[10]
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        BinNo: Code[10];
        MissingFixedBinErr: Label 'You must specify a value for the "Fixed Bin" parameter, when "Bin Selection" paremeter is set to value "Fixed Bin".';
    begin
        BinNo := CopyStr(Context.GetStringParameter('SourceBin'), 1, 10);
        if BinNo = '' then
            Error(MissingFixedBinErr);
        POSPaymentBin.Get(BinNo);
        exit(POSPaymentBin."No.");
    end;

    local procedure AddPostWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") PostWorkflows: JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        BinTransferEvents: Codeunit "NPR POS Action Publishers";
    begin
        PostWorkflows.ReadFrom('{}');
        Sale.GetCurrentSale(SalePOS);
        BinTransferEvents.OnAddPostWorkflowsToRun(Context, SalePOS, PostWorkflows);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionBinTransfer.js###
'let main=async({workflow:t})=>{let{legacyAction:a,binTransferContextData:n,postWorkflows:e}=await t.respond("PrepareWorkflow");if(a)return await t.respond("RunLegacyAction");let o=await popup.binTransfer(n),{success:s,checkpointEntryNo:i}=await t.respond("ProcessBinTranser",{returnedData:o});if(!!s&&e)for(const c of Object.entries(e)){let[r,p]=c;r&&await t.run(r,{context:{transferResult:{checkpointEntryNo:i}},parameters:p})}};'
        );
    end;
}
