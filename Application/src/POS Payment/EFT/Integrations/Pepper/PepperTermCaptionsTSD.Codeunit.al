#if not CLOUD
codeunit 6184498 "NPR Pepper Term. Captions TSD"
{
    Access = Internal;
    ObsoleteReason = 'Use HWC';
    ObsoleteState = Pending;

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

#if not CLOUD
    [Obsolete('Use HWC')]
    procedure GetLabels(var ProcessLabels: DotNet NPRNetProcessLabels0)
    begin
        ProcessLabels := ProcessLabels.ProcessLabels();

        ProcessLabels.ButtonCloseCaption := ButtonCloseCaption;
        ProcessLabels.ConfirmAbandonTransaction := ConfirmAbandonTransaction;
        ProcessLabels.ConfirmContinueWaitOnTimeout := ConfirmContinueWaitOnTimeout;
        ProcessLabels.EftInitialDisplayText := EftInitialDisplayText;
        ProcessLabels.LblAuxiliaryFunction := LblAuxiliaryFunction;
        ProcessLabels.LblCleanupDriver := LblCleanupDriver;
        ProcessLabels.LblClose := LblClose;
        ProcessLabels.LblConfigDriver := LblConfigDriver;
        ProcessLabels.LblEndOfDayReceipt := LblEndOfDayReceipt;
        ProcessLabels.LblError := LblError;
        ProcessLabels.LblHeaderFooterFiles := LblHeaderFooterFiles;
        ProcessLabels.LblInitializeLibrary := LblInitializeLibrary;
        ProcessLabels.LblOpen := LblOpen;
        ProcessLabels.LblPleaseWait := LblPleaseWait;
        ProcessLabels.LblRegisterCallback := LblRegisterCallback;
        ProcessLabels.LblSuccess := LblSuccess;
        ProcessLabels.LblTrx_0 := LblTrx_0;
        ProcessLabels.LblTrx_10 := LblTrx_10;
        ProcessLabels.LblTrx_20 := LblTrx_20;
        ProcessLabels.LblTrx_60 := LblTrx_60;
        ProcessLabels.LblTrx_200 := LblTrx_200;
        ProcessLabels.LblUnloadLibrary := LblUnloadLibrary;
        ProcessLabels.LblWaitingEndOfDayReceipt := LblWaitingEndOfDayReceipt;
        ProcessLabels.LblWaitingForReceipt := LblWaitingForReceipt;
        ProcessLabels.WindowTitle := WindowTitle;
        ProcessLabels.PepperEftStatus_0 := PepperEftStatus_0;
        ProcessLabels.PepperEftStatus_1 := PepperEftStatus_1;
        ProcessLabels.PepperEftStatus_2 := PepperEftStatus_2;
        ProcessLabels.PepperEftStatus_3 := PepperEftStatus_3;
        ProcessLabels.PepperEftStatus_4 := PepperEftStatus_4;
        ProcessLabels.PepperEftStatus_5 := PepperEftStatus_5;
        ProcessLabels.PepperEftStatus_6 := PepperEftStatus_6;
        ProcessLabels.PepperEftStatus_7 := PepperEftStatus_7;
        ProcessLabels.PepperEftStatus_8 := PepperEftStatus_8;
    end;
#endif

}
#endif
