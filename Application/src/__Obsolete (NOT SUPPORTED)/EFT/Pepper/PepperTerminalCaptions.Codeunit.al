codeunit 6184485 "NPR Pepper Terminal Captions"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    var
        LblTrx_0: Label 'Recovering Last Transaction...';
        LblTrx_10: Label 'Payment of Goods...';
        LblTrx_20: Label 'Voiding Transaction...';
        LblTrx_60: Label 'Refunding Transaction...';
        LblTrx_200: Label 'Result Request...';
        LblInitializeLibrary: Label 'Initializing Library...';
        LblConfigDriver: Label 'Configuring Driver...';
        LblRegisterCallback: Label 'Register Callbacks...';
        LblOpen: Label 'Opening Terminal...';
        LblClose: Label 'Closing Terminal...';
        LblCleanupDriver: Label 'Cleaning up driver...';
        LblHeaderFooterFiles: Label 'Headers & Footers...';
        LblWaitingForReceipt: Label 'Waiting For Receipt...';
        LblError: Label 'Error';
        LblSuccess: Label 'Success';
        LblEndOfDayReceipt: Label 'End of Day Receipt...';
        LblWaitingEndOfDayReceipt: Label 'Waiting for End of Day Receipt...';
        LblUnloadLibrary: Label 'Unloading Library...';
        LblPleaseWait: Label 'Please Wait...';
        LblAuxiliaryFunction: Label 'Auxiliary Function...';
        ConfirmContinueWaitOnTimeout: Label 'The transaction is taking longer than usual. Do you want to continue waiting?';
        ConfirmAbandonTransaction: Label 'Warning, this will abandon the transaction on the terminal! As a result, the POS and terminal could be out-of-sync. Do you want to abondon the transactions?';
        ButtonCloseCaption: Label 'Cancel';
        WindowTitle: Label 'Pepper Payment Terminal';
        EftInitialDisplayText: Label 'Welcome';
        PepperEftStatus_0: Label 'No status available';
        PepperEftStatus_1: Label 'Inactive';
        PepperEftStatus_2: Label 'Active';
        PepperEftStatus_3: Label 'Active, card inserted';
        PepperEftStatus_4: Label 'Active, card inserted, PIN not OK';
        PepperEftStatus_5: Label 'Active, card inserted, PIN OK, or no PIN requested';
        PepperEftStatus_6: Label 'Active, transaction is being processed';
        PepperEftStatus_7: Label 'Terminal busy, no active transaction';
        PepperEftStatus_8: Label '- - -';

        LblInstalling: Label 'Installing...';
        LblDownloading: Label 'Downloading...';
        LblFolderDeleteFailed: Label 'Removing the previous Pepper installation failed because the folder could not be moved. Close Pepper integration and try again.';
        LblPepperIsOpen: Label 'Pepper must be in closed state prior to install. Don''t forget to do end of day before installing the new version.';
        LblDeclineTransactionResultText: Label 'Declined';
        LblOkTransactionResultText: Label 'Ok';

    procedure GetLabels(var ProcessLabels: JsonObject)
    begin

        ProcessLabels.ReadFrom('{}');

        ProcessLabels.Add('ButtonCloseCaption', ButtonCloseCaption);
        ProcessLabels.Add('ConfirmAbandonTransaction', ConfirmAbandonTransaction);
        ProcessLabels.Add('ConfirmContinueWaitOnTimeout', ConfirmContinueWaitOnTimeout);
        ProcessLabels.Add('EftInitialDisplayText', EftInitialDisplayText);
        ProcessLabels.Add('LblAuxiliaryFunction', LblAuxiliaryFunction);
        ProcessLabels.Add('LblCleanupDriver', LblCleanupDriver);
        ProcessLabels.Add('LblClose', LblClose);
        ProcessLabels.Add('LblConfigDriver', LblConfigDriver);
        ProcessLabels.Add('LblEndOfDayReceipt', LblEndOfDayReceipt);
        ProcessLabels.Add('LblError', LblError);
        ProcessLabels.Add('LblHeaderFooterFiles', LblHeaderFooterFiles);
        ProcessLabels.Add('LblInitializeLibrary', LblInitializeLibrary);
        ProcessLabels.Add('LblOpen', LblOpen);
        ProcessLabels.Add('LblPleaseWait', LblPleaseWait);
        ProcessLabels.Add('LblRegisterCallback', LblRegisterCallback);
        ProcessLabels.Add('LblSuccess', LblSuccess);
        ProcessLabels.Add('LblTrx_0', LblTrx_0);
        ProcessLabels.Add('LblTrx_10', LblTrx_10);
        ProcessLabels.Add('LblTrx_20', LblTrx_20);
        ProcessLabels.Add('LblTrx_60', LblTrx_60);
        ProcessLabels.Add('LblTrx_200', LblTrx_200);
        ProcessLabels.Add('LblUnloadLibrary', LblUnloadLibrary);
        ProcessLabels.Add('LblWaitingEndOfDayReceipt', LblWaitingEndOfDayReceipt);
        ProcessLabels.Add('LblWaitingForReceipt', LblWaitingForReceipt);
        ProcessLabels.Add('WindowTitle', WindowTitle);
        ProcessLabels.Add('PepperEftStatus_0', PepperEftStatus_0);
        ProcessLabels.Add('PepperEftStatus_1', PepperEftStatus_1);
        ProcessLabels.Add('PepperEftStatus_2', PepperEftStatus_2);
        ProcessLabels.Add('PepperEftStatus_3', PepperEftStatus_3);
        ProcessLabels.Add('PepperEftStatus_4', PepperEftStatus_4);
        ProcessLabels.Add('PepperEftStatus_5', PepperEftStatus_5);
        ProcessLabels.Add('PepperEftStatus_6', PepperEftStatus_6);
        ProcessLabels.Add('PepperEftStatus_7', PepperEftStatus_7);
        ProcessLabels.Add('PepperEftStatus_8', PepperEftStatus_8);
        ProcessLabels.Add('LblInstalling', LblInstalling);
        ProcessLabels.Add('LblDownloading', LblDownloading);
        ProcessLabels.Add('LblFolderDeleteFailed', LblFolderDeleteFailed);
        ProcessLabels.Add('LblPepperIsOpen', LblPepperIsOpen);
        ProcessLabels.Add('LblDeclineTransactionResultText', LblDeclineTransactionResultText);
        ProcessLabels.Add('LblOkTransactionResultText', LblOkTransactionResultText);

    end;

}

