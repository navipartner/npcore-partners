codeunit 6014617 "NPR TaxFree GBI2 GetCountries"
{
    Access = Internal;
    // Codeunit is intended to be scheduled for NAS for customers running a Global Blue I2 Tax Free integration, for monthly execution.
    // It retrieves and stores a list of enduser countries for use in the I2 integration flow.


    trigger OnRun()
    var
        TaxFreeRequest: Record "NPR Tax Free Request";
        GlobalBlueHandler: Codeunit "NPR Tax Free GB I2";
        TaxFreeProfile: Record "NPR POS Tax Free Profile";
    begin
        if not FindValidTaxFreeUnit(TaxFreeProfile) then
            Error(Error_MissingParams);

        TaxFreeRequest.Init();
        TaxFreeRequest."Request Type" := 'GET_COUNTRIES';
        TaxFreeRequest."POS Unit No." := '';
        TaxFreeRequest.Mode := TaxFreeProfile.Mode;
        TaxFreeRequest."Timeout (ms)" := 300 * 1000;
        TaxFreeRequest."Time Start" := Time;
        TaxFreeRequest."Date Start" := Today();
        TaxFreeRequest."Tax Free Profile" := TaxFreeProfile."Tax Free Profile";

        GlobalBlueHandler.InitializeHandler(TaxFreeRequest);
        GlobalBlueHandler.DownloadCountries(TaxFreeRequest);
    end;

    var
        Error_MissingParams: Label 'No valid handler parameters found';

    local procedure FindValidTaxFreeUnit(var TaxFreeProfile: Record "NPR POS Tax Free Profile"): Boolean
    var
        GlobalBlueParameters: Record "NPR Tax Free GB I2 Param.";
    begin
        TaxFreeProfile.SetRange("Handler ID Enum", TaxFreeProfile."Handler ID Enum"::GLOBALBLUE_I2);
        TaxFreeProfile.FindSet();
        repeat
            GlobalBlueParameters.SetFilter("Shop ID", '<>%1', '');
            GlobalBlueParameters.SetFilter("Desk ID", '<>%1', '');
            GlobalBlueParameters.SetFilter("Shop Country Code", '<>%1', 0);
            GlobalBlueParameters.SetRange("Tax Free Unit", TaxFreeProfile."Tax Free Profile");
            if GlobalBlueParameters.FindFirst() then
                exit(true);
        until TaxFreeProfile.Next() = 0;
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

