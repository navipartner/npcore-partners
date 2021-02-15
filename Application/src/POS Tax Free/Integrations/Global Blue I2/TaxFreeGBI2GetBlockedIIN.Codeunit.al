codeunit 6014616 "NPR TaxFree GBI2 GetBlockedIIN"
{
    // Codeunit is intended to be scheduled for NAS for customers running a Global Blue I2 Tax Free integration, for monthly execution.
    // It retrieves and stores a list of EFT IIN numbers that identify ineligible card hold countries.


    trigger OnRun()
    var
        TaxFreeRequest: Record "NPR Tax Free Request";
        GlobalBlueHandler: Codeunit "NPR Tax Free GB I2";
        tmpTaxFreeUnit: Record "NPR Tax Free POS Unit" temporary;
    begin
        if not FindUniqueCountryTaxFreeUnits(tmpTaxFreeUnit) then
            Error(Error_MissingParams);

        tmpTaxFreeUnit.FindSet;
        repeat
            TaxFreeRequest.Init;
            TaxFreeRequest."Request Type" := 'GET_IIN_BLACKLIST';
            TaxFreeRequest."POS Unit No." := tmpTaxFreeUnit."POS Unit No.";
            TaxFreeRequest.Mode := tmpTaxFreeUnit.Mode;
            TaxFreeRequest."Timeout (ms)" := 300 * 1000;
            TaxFreeRequest."Time Start" := Time;
            TaxFreeRequest."Date Start" := Today;

            GlobalBlueHandler.InitializeHandler(TaxFreeRequest);
            GlobalBlueHandler.DownloadCondensedTred(TaxFreeRequest);
            Clear(TaxFreeRequest);
            Clear(GlobalBlueHandler);
        until tmpTaxFreeUnit.Next = 0;
    end;

    var
        Error_MissingParams: Label 'No valid handler parameters found';

    local procedure FindUniqueCountryTaxFreeUnits(var tmpTaxFreeUnit: Record "NPR Tax Free POS Unit" temporary): Boolean
    var
        GlobalBlueHandler: Codeunit "NPR Tax Free GB I2";
        GlobalBlueParameters: Record "NPR Tax Free GB I2 Param.";
        TaxFreeUnit: Record "NPR Tax Free POS Unit";
        tmpInteger: Record "Integer" temporary;
    begin
        TaxFreeUnit.SetRange("Handler ID Enum", TaxFreeUnit."Handler ID Enum"::GLOBALBLUE_I2);
        TaxFreeUnit.FindSet;
        repeat
            GlobalBlueParameters.SetFilter("Shop ID", '<>%1', '');
            GlobalBlueParameters.SetFilter("Desk ID", '<>%1', '');
            GlobalBlueParameters.SetFilter("Shop Country Code", '<>%1', 0);
            GlobalBlueParameters.SetRange("Tax Free Unit", TaxFreeUnit."POS Unit No.");
            if GlobalBlueParameters.FindFirst then begin
                if not tmpInteger.Get(GlobalBlueParameters."Shop Country Code") then begin
                    tmpInteger.Init;
                    tmpInteger.Number := GlobalBlueParameters."Shop Country Code";
                    tmpInteger.Insert;
                    tmpTaxFreeUnit.Init;
                    tmpTaxFreeUnit.TransferFields(TaxFreeUnit);
                    tmpTaxFreeUnit.Insert;
                end;
            end;
        until TaxFreeUnit.Next = 0;

        exit(not tmpTaxFreeUnit.IsEmpty);
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

