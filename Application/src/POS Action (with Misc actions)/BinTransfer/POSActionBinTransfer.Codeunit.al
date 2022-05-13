codeunit 6150851 "NPR POS Action: Bin Transfer" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Transfer funds from one bin to another using the POS.';
        SourceBinSelectionLbl: Label 'SourceBinSelection';
        SourceBinOptionsLbl: Label 'PosUnitDefaultBin,UserSelection,FixedParameter';
        SourceBinSelection_NameLbl: Label 'Source Bin Selection';
        SourceBinOptions_CptLbl: Label 'POS Unit Default Bin,User Selection,Fixed Parametar';
        SourceBin_NameLbl: Label 'SourceBin';
        SourceBin_CptLbl: Label 'Source Bin';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(
            SourceBinSelectionLbl,
            SourceBinOptionsLbl,
            SelectStr(1, SourceBinOptionsLbl),
            SourceBinSelection_NameLbl,
            SourceBinSelection_NameLbl,
            SourceBinOptions_CptLbl);
        WorkflowConfig.AddTextParameter(SourceBin_NameLbl, '', SourceBin_CptLbl, SourceBin_CptLbl);

    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin

        case Step of
            'SelectBin':
                FrontEnd.WorkflowResponse(SelectSourceBin(Context));
            'Transfer':
                FrontEnd.WorkflowResponse(TransferContentsToBin(Context, Sale));
        end;
    end;

    procedure TransferContentsToBin(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale"): JsonObject
    var
        CheckpointEntryNo: Integer;
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        FromBinNo: Code[10];
        POSSession: Codeunit "NPR POS Session";
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
    begin

        FromBinNo := CopyStr(Context.GetString('FROM_BIN'), 1, MaxStrLen(FromBinNo));
        CheckpointEntryNo := POSWorkshiftCheckpoint.CreateEndWorkshiftCheckpoint_POSEntry(FromBinNo);
        POSActionBinTransferB.TransferContentsToBin(POSSession, FromBinNo, CheckpointEntryNo);

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

    local procedure GetFixedBin(Context: Codeunit "NPR POS JSON Helper"): Code[10]
    begin

        exit(CopyStr(Context.GetStringParameter('SourceBin'), 1, 10));
    end;

    local procedure GetActionScript(): Text
    begin

        exit(
        //###NPR_INJECT_FROM_FILE:POSActionBinTransfer.js###
'let main=async({parametars:r,context:e})=>(SourceBin=await workflow.respond("SelectBin"),await workflow.respond("Transfer",SourceBin));'
        );
    end;
}

