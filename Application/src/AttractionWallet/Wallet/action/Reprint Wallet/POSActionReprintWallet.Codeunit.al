codeunit 6248257 "NPR POS Action Reprint Wallet" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        DescriptionLbl: Label 'Action for Attraction Wallet reprint', Comment = 'Description of the action';
        TitleLbl: Label 'Reprint Attraction Wallet', Comment = 'Title of the action';
        ReferenceNoPromptLbl: Label 'Enter Reference No.', Comment = 'Prompt for reference no.';
        ReferenceNoRequiredLbl: Label 'Reference No. is required', Comment = 'Error message for missing reference no.';

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(DescriptionLbl);

        WorkflowConfig.AddLabel('title', TitleLbl);
        WorkflowConfig.AddLabel('referenceNoPrompt', ReferenceNoPromptLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'ReprintWallet':
                ReprintWallet(Context);
        end;
    end;

    local procedure ReprintWallet(Context: Codeunit "NPR POS JSON Helper")
    var
        AttractionWalletFacade: Codeunit "NPR AttractionWalletFacade";
        WalletEntryNoList: List of [Integer];
        ReferenceNo: Text;
    begin
        ReferenceNo := Context.GetString('ReferenceNo');
        if ReferenceNo = '' then
            Error(ReferenceNoRequiredLbl);

        FindWallets(ReferenceNo, WalletEntryNoList);
        AttractionWalletFacade.PrintWallet(WalletEntryNoList, Enum::"NPR WalletPrintType"::WALLET);
    end;

    local procedure FindWallets(ReferenceNo: Text; var _WalletEntryNoList: List of [Integer])
    var
        POSEntry: Record "NPR POS Entry";
    begin
        if StrLen(ReferenceNo) <= MaxStrLen(POSEntry."Document No.") then begin
            POSEntry.SetRange("Document No.", (CopyStr(ReferenceNo, 1, MaxStrLen(POSEntry."Document No."))));
            if POSEntry.FindFirst() then
                FindWalletsFromPOSSale(POSEntry.SystemId, _WalletEntryNoList);
        end;

        if (_WalletEntryNoList.Count = 0) then
            FindWalletDirectly(CopyStr(ReferenceNo, 1, 100), _WalletEntryNoList);
    end;

    local procedure FindWalletsFromPOSSale(POSEntrySystemId: Guid; var _WalletEntryNoList: List of [Integer])
    var
        Wallet: Record "NPR AttractionWallet";
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        AssetHeader: Record "NPR WalletAssetHeader";
        AssetLine: Record "NPR WalletAssetLine";
    begin
        WalletAssetHeaderRef.SetCurrentKey(LinkToReference, SupersededBy);
        WalletAssetHeaderRef.SetRange(LinkToTableId, Database::"NPR POS Entry");
        WalletAssetHeaderRef.SetRange(LinkToSystemId, POSEntrySystemId);
        WalletAssetHeaderRef.SetRange(SupersededBy, 0);
        if WalletAssetHeaderRef.FindSet() then
            repeat
                AssetHeader.Get(WalletAssetHeaderRef.WalletHeaderEntryNo);

                AssetLine.SetCurrentKey(TransactionId);
                AssetLine.SetRange(TransactionId, AssetHeader.TransactionId);
                AssetLine.SetRange(Type, Enum::"NPR WalletLineType"::WALLET);
                if AssetLine.FindSet() then
                    repeat
                        Wallet.Reset();
                        Wallet.GetBySystemId(AssetLine.LineTypeSystemId);
                        if not _WalletEntryNoList.Contains(Wallet.EntryNo) then
                            _WalletEntryNoList.Add(Wallet.EntryNo);
                    until AssetLine.Next() = 0;
            until WalletAssetHeaderRef.Next() = 0;
    end;

    local procedure FindWalletDirectly(ReferenceNo: Text[100]; var _WalletEntryNoList: List of [Integer])
    var
        Wallet: Record "NPR AttractionWallet";
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
    begin
        WalletExternalReference.SetLoadFields(WalletEntryNo);
        if (WalletExternalReference.Get(ReferenceNo)) then
            Wallet.SetRange(EntryNo, WalletExternalReference.WalletEntryNo)
        else
            if (StrLen(ReferenceNo) <= MaxStrLen(Wallet.ReferenceNumber)) then begin
                Wallet.SetCurrentKey(ReferenceNumber);
                Wallet.SetRange(ReferenceNumber, ReferenceNo);
            end else
                exit;

        if Wallet.FindFirst() then
            if not _WalletEntryNoList.Contains(Wallet.EntryNo) then
                _WalletEntryNoList.Add(Wallet.EntryNo);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionReprintWallet.Codeunit.js###
        'const main=async({workflow:n,popup:i,captions:e})=>{const t=await i.input({title:e.title,caption:e.referenceNoPrompt});t!==null&&await n.respond("ReprintWallet",{ReferenceNo:t})};'
        );
    end;
}
