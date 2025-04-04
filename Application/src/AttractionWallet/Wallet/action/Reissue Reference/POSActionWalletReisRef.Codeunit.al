codeunit 6248390 "NPR POSActionWalletReisRef" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescLbl: Label 'Allows the user to scan an wallet external reference, block all external references of the wallet, issue a new one, and print the wallet again.';
        InputWalletRefernceLbl: Label 'Input Wallet Reference';
        WalletNotFoundLbl: Label 'No wallet could be found from specified reference number';
        WalletRefAlreadyBlockedLbl: Label 'The entered external reference is already blocked. New reference not created.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescLbl);
        WorkflowConfig.AddLabel('inputReference', InputWalletRefernceLbl);
        WorkflowConfig.AddLabel('noWalletFound', WalletNotFoundLbl);
        WorkflowConfig.AddLabel('walletRefAlreadyBlocked', WalletRefAlreadyBlockedLbl);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup")
    var
        AttractionWallet: Codeunit "NPR AttractionWallet";
        Input: Text;
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
        Wallet: Record "NPR AttractionWallet";
    begin
        case Step of
            'reIssue':
                begin
                    Input := Context.GetString('input');

                    if (StrLen(Input) > MaxStrLen(WalletExternalReference.ExternalReference)) then begin
                        FrontEnd.WorkflowResponse(RespondWalletNotFound());
                        exit;
                    end;

                    WalletExternalReference.SetLoadFields(ExternalReference, WalletEntryNo, BlockedAt);
                    if (not WalletExternalReference.Get(Input)) then begin
                        FrontEnd.WorkflowResponse(RespondWalletNotFound());
                        exit;
                    end;

                    if (WalletExternalReference.BlockedAt <> 0DT) then begin
                        FrontEnd.WorkflowResponse(RespondWalletRefAlreadyBlocked());
                        exit;
                    end;

                    if (not Wallet.Get(WalletExternalReference.WalletEntryNo)) then begin
                        FrontEnd.WorkflowResponse(RespondWalletNotFound());
                        exit;
                    end;

                    AttractionWallet.BlockAllExternalReferences(Wallet.EntryNo);
                    AttractionWallet.CreateNewExternalReference(Wallet);
                    Commit();

                    AttractionWallet.PrintWallet(Wallet.EntryNo, "NPR WalletPrintType"::WALLET);

                    FrontEnd.WorkflowResponse(RespondSuccess());
                end;
        end;
    end;

    local procedure RespondWalletNotFound() Params: JsonObject
    begin
        Params.Add('success', false);
        Params.Add('reason', 'walletNotFound');
    end;

    local procedure RespondWalletRefAlreadyBlocked() Params: JsonObject
    begin
        Params.Add('success', false);
        Params.Add('reason', 'walletRefAlreadyBlocked');
    end;

    local procedure RespondSuccess() Params: JsonObject
    begin
        Params.Add('success', true);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
            //###NPR_INJECT_FROM_FILE:POSActionWalletReisRef.js###
            'const main=async({popup:e,captions:a,workflow:n})=>{const t=await e.input(a.inputReference);if(!t)return;const{success:r,reason:s}=await n.respond("reIssue",{input:t});if(!r)switch(s){case"walletNotFound":{await e.message(a.noWalletFound);return}case"walletRefAlreadyBlocked":{await e.message(a.walletRefAlreadyBlocked);return}}};'
        );
    end;
}