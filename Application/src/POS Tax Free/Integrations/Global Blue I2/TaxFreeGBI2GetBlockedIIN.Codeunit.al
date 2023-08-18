codeunit 6014616 "NPR TaxFree GBI2 GetBlockedIIN"
{
    Access = Internal;
    // Codeunit is intended to be scheduled for NAS for customers running a Global Blue I2 Tax Free integration, for monthly execution.
    // It retrieves and stores a list of EFT IIN numbers that identify ineligible card hold countries.


    trigger OnRun()
    var
        TaxFreeRequest: Record "NPR Tax Free Request";
        GlobalBlueHandler: Codeunit "NPR Tax Free GB I2";
        TempTaxFreeProfile: Record "NPR POS Tax Free Profile" temporary;
    begin
        if not FindUniqueCountryTaxFreeUnits(TempTaxFreeProfile) then
            Error(Error_MissingParams);

        TempTaxFreeProfile.FindSet();
        repeat
            TaxFreeRequest.Init();
            TaxFreeRequest."Request Type" := 'GET_IIN_BLACKLIST';
            TaxFreeRequest."POS Unit No." := '';
            TaxFreeRequest.Mode := TempTaxFreeProfile.Mode;
            TaxFreeRequest."Timeout (ms)" := 300 * 1000;
            TaxFreeRequest."Time Start" := Time;
            TaxFreeRequest."Date Start" := Today();
            TaxFreeRequest."Tax Free Profile" := TempTaxFreeProfile."Tax Free Profile";

            GlobalBlueHandler.InitializeHandler(TaxFreeRequest);
            GlobalBlueHandler.DownloadCondensedTred(TaxFreeRequest);
            Clear(TaxFreeRequest);
            Clear(GlobalBlueHandler);
        until TempTaxFreeProfile.Next() = 0;
    end;

    var
        Error_MissingParams: Label 'No valid handler parameters found';

    local procedure FindUniqueCountryTaxFreeUnits(var tmpTaxFreeProfile: Record "NPR POS Tax Free Profile" temporary): Boolean
    var
        GlobalBlueParameters: Record "NPR Tax Free GB I2 Param.";
        TaxFreeProfile: Record "NPR POS Tax Free Profile";
        TempInteger: Record "Integer" temporary;
    begin
        TaxFreeProfile.SetRange("Handler ID Enum", TaxFreeProfile."Handler ID Enum"::GLOBALBLUE_I2);
        TaxFreeProfile.FindSet();
        repeat
            GlobalBlueParameters.SetFilter("Shop ID", '<>%1', '');
            GlobalBlueParameters.SetFilter("Desk ID", '<>%1', '');
            GlobalBlueParameters.SetFilter("Shop Country Code", '<>%1', 0);
            GlobalBlueParameters.SetRange("Tax Free Unit", TaxFreeProfile."Tax Free Profile");
            if GlobalBlueParameters.FindFirst() then begin
                if not TempInteger.Get(GlobalBlueParameters."Shop Country Code") then begin
                    TempInteger.Init();
                    TempInteger.Number := GlobalBlueParameters."Shop Country Code";
                    TempInteger.Insert();
                    tmpTaxFreeProfile.Init();
                    tmpTaxFreeProfile.TransferFields(TaxFreeProfile);
                    tmpTaxFreeProfile.Insert();
                end;
            end;
        until TaxFreeProfile.Next() = 0;

        exit(not tmpTaxFreeProfile.IsEmpty());
    end;

    procedure IsScheduled(): Boolean
    begin
        //Is task queue configured?
    end;

    procedure Schedule(): Boolean
    begin
        //Create Task Queue job
    end;
}

