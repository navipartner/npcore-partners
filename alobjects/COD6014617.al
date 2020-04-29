codeunit 6014617 "Tax Free GB I2 GetCountries"
{
    // Codeunit is intended to be scheduled for NAS for customers running a Global Blue I2 Tax Free integration, for monthly execution.
    // It retrieves and stores a list of enduser countries for use in the I2 integration flow.
    // 
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module


    trigger OnRun()
    var
        TaxFreeRequest: Record "Tax Free Request";
        GlobalBlueHandler: Codeunit "Tax Free GB I2";
        TaxFreeUnit: Record "Tax Free POS Unit";
    begin
        if not FindValidTaxFreeUnit(TaxFreeUnit) then
          Error(Error_MissingParams);

        TaxFreeRequest.Init;
        TaxFreeRequest."Request Type" := 'GET_COUNTRIES';
        TaxFreeRequest."POS Unit No." := TaxFreeUnit."POS Unit No.";
        TaxFreeRequest.Mode := TaxFreeUnit.Mode;
        TaxFreeRequest."Timeout (ms)" := 300 * 1000;
        TaxFreeRequest."Time Start" := Time;
        TaxFreeRequest."Date Start" := Today;

        GlobalBlueHandler.InitializeHandler(TaxFreeRequest);
        GlobalBlueHandler.DownloadCountries(TaxFreeRequest);
    end;

    var
        Error_MissingParams: Label 'No valid handler parameters found';

    local procedure FindValidTaxFreeUnit(var TaxFreeUnit: Record "Tax Free POS Unit"): Boolean
    var
        GlobalBlueHandler: Codeunit "Tax Free GB I2";
        GlobalBlueParameters: Record "Tax Free GB I2 Parameter";
    begin
        TaxFreeUnit.SetRange("Handler ID", GlobalBlueHandler.HandlerID);
        TaxFreeUnit.FindSet;
        repeat
          GlobalBlueParameters.SetFilter("Shop ID", '<>%1', '');
          GlobalBlueParameters.SetFilter("Desk ID", '<>%1', '');
          GlobalBlueParameters.SetFilter("Shop Country Code", '<>%1', 0);
          GlobalBlueParameters.SetRange("Tax Free Unit", TaxFreeUnit."POS Unit No.");
          if GlobalBlueParameters.FindFirst then
            exit(true);
        until TaxFreeUnit.Next = 0;
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

