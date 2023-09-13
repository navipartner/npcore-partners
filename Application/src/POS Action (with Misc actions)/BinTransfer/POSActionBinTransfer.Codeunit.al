codeunit 6150851 "NPR POS Action: Bin Transfer" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        PrintTransferNameLbl: Label 'PrintTransfer', Locked = true;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Transfer funds from one bin to another using the POS.';
        SourceBinSelectionLbl: Label 'SourceBinSelection', Locked = true;
        SourceBinOptionsLbl: Label 'PosUnitDefaultBin,UserSelection,FixedParameter', Locked = true;
        SourceBinSelection_NameLbl: Label 'Source Bin Selection';
        SourceBinOptions_CptLbl: Label 'POS Unit Default Bin,User Selection,Fixed Parametar';
        SourceBin_NameLbl: Label 'SourceBin';
        SourceBin_CptLbl: Label 'Source Bin';
        PrintTransferCaptionNameLbl: Label 'Print Transfer Out';
        PrintTransferCaptionDescriptionLbl: Label 'Print template from Report Selection - Retail, after transferring out content from bin. Template need to be built on top of "Workshift Checkpoint" table.';
        TransferDirection: Label 'TransferDirection', Locked = true;
        TransferDirectionCaption: Label 'Transfer Direction';
        TransferDirectionDescription: Label 'Transfer Direction';
        TransferDirectionOption: Label ',TransferOut,TransferIn', Locked = true;
        TransferDirectionOptionCaption: Label ',Transfer Out,Transfer In';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(
            SourceBinSelectionLbl,
            SourceBinOptionsLbl,
#pragma warning disable AA0139
            SelectStr(1, SourceBinOptionsLbl),
#pragma warning restore 
            SourceBinSelection_NameLbl,
            SourceBinSelection_NameLbl,
            SourceBinOptions_CptLbl);
        WorkflowConfig.AddBooleanParameter(PrintTransferNameLbl, false, PrintTransferCaptionNameLbl, PrintTransferCaptionDescriptionLbl);
        WorkflowConfig.AddTextParameter(SourceBin_NameLbl, '', SourceBin_CptLbl, SourceBin_CptLbl);
        WorkflowConfig.AddOptionParameter(TransferDirection, TransferDirectionOption, '', TransferDirectionCaption, TransferDirectionDescription, TransferDirectionOptionCaption);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin

        case Step of
            'SelectBin':
                FrontEnd.WorkflowResponse(SelectSourceBin(Context));
            'TransferOut':
                FrontEnd.WorkflowResponse(TransferContentsOutFromBin(Context, Sale));
            'TransferIn':
                FrontEnd.WorkflowResponse(TransferContentsInToBin(Setup));
        end;
    end;

    procedure TransferContentsOutFromBin(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale"): JsonObject
    var
        CheckpointEntryNo: Integer;
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        FromBinNo: Code[10];
        POSSession: Codeunit "NPR POS Session";
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
        PrintTransfer: Boolean;
        PosUnit: Record "NPR POS Unit";
    begin
        FromBinNo := CopyStr(Context.GetString('FROM_BIN'), 1, MaxStrLen(FromBinNo));
        POSActionBinTransferB.GetPosUnitFromBin(FromBinNo, PosUnit);
        CheckpointEntryNo := POSWorkshiftCheckpoint.CreateEndWorkshiftCheckpoint_POSEntry(PosUnit."POS Store Code", PosUnit."No.", PosUnit.Status);

        POSActionBinTransferB.TransferContentsToBin(POSSession, FromBinNo, CheckpointEntryNo);
        if Context.GetBooleanParameter(PrintTransferNameLbl, PrintTransfer) and PrintTransfer then
            POSActionBinTransferB.PrintBinTransfer(CheckpointEntryNo);
    end;

    local procedure SelectSourceBin(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        FromBinNo: Code[10];
        SourceBinSelection: Integer;
        POSSession: Codeunit "NPR POS Session";
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
    begin

        SourceBinSelection := Context.GetIntegerParameter('SourceBinSelection');
        case SourceBinSelection of
            1:
                FromBinNo := POSActionBinTransferB.UserSelectBin(POSSession);
            2:
                FromBinNo := GetFixedBin(Context);
            else
                FromBinNo := POSActionBinTransferB.GetDefaultUnitBin(POSSession);
        end;
        Response.ReadFrom('{}');
        Response.Add('FROM_BIN', FromBinNo);
    end;

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
    begin

        exit(CopyStr(Context.GetStringParameter('SourceBin'), 1, 10));
    end;

    local procedure GetActionScript(): Text
    begin

        exit(
        //###NPR_INJECT_FROM_FILE:POSActionBinTransfer.js###
'let main=async({workflow:e,parameters:n})=>{debugger;if(n.TransferDirection==n.TransferDirection.TransferIn)return await e.respond("TransferIn");{let r=await e.respond("SelectBin");return await e.respond("TransferOut",r)}};'
        );
    end;
}

