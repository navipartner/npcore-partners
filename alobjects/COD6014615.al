codeunit 6014615 "Tax Free GB I2 GetBCountries"
{
    // Codeunit is intended to be scheduled for NAS for customers running a Global Blue I2 Tax Free integration, for weekly execution.
    // It retrieves and stores a list of blocked enduser countries for use in the I2 integration flow.
    // 
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module


    trigger OnRun()
    var
        TaxFreeRequest: Record "Tax Free Request";
        GlobalBlueHandler: Codeunit "Tax Free GB I2";
        tmpTaxFreeUnit: Record "Tax Free POS Unit" temporary;
    begin
        if not FindUniqueCountryTaxFreeUnits(tmpTaxFreeUnit) then
          Error(Error_MissingParams);

        tmpTaxFreeUnit.FindSet;
        repeat
          TaxFreeRequest.Init;
          TaxFreeRequest."Request Type" := 'GET_BLOCKED_COUNTRIES';
          TaxFreeRequest."POS Unit No." := tmpTaxFreeUnit."POS Unit No.";
          TaxFreeRequest.Mode := tmpTaxFreeUnit.Mode;
          TaxFreeRequest."Timeout (ms)" := 300 * 1000;
          TaxFreeRequest."Time Start" := Time;
          TaxFreeRequest."Date Start" := Today;

          GlobalBlueHandler.InitializeHandler(TaxFreeRequest);
          GlobalBlueHandler.DownloadBlockedCountries(TaxFreeRequest);
          Clear(TaxFreeRequest);
          Clear(GlobalBlueHandler);
        until tmpTaxFreeUnit.Next = 0;
    end;

    var
        Error_MissingParams: Label 'No valid handler parameters found';

    local procedure FindUniqueCountryTaxFreeUnits(var tmpTaxFreeUnit: Record "Tax Free POS Unit" temporary): Boolean
    var
        GlobalBlueHandler: Codeunit "Tax Free GB I2";
        GlobalBlueParameters: Record "Tax Free GB I2 Parameter";
        TaxFreeUnit: Record "Tax Free POS Unit";
        tmpInteger: Record "Integer" temporary;
    begin
        TaxFreeUnit.SetRange("Handler ID", GlobalBlueHandler.HandlerID);
        TaxFreeUnit.FindSet;
        repeat
          GlobalBlueParameters.SetFilter("Shop ID", '<>%1', '');
          GlobalBlueParameters.SetFilter("Desk ID", '<>%1', '');
          GlobalBlueParameters.SetFilter("Shop Country Code", '<>%1', 0);
          GlobalBlueParameters.SetRange("Tax Free Unit", TaxFreeUnit."POS Unit No.");
          if GlobalBlueParameters.FindFirst then
            if not tmpInteger.Get(GlobalBlueParameters."Shop Country Code") then begin
              tmpInteger.Init;
              tmpInteger.Number := GlobalBlueParameters."Shop Country Code";
              tmpInteger.Insert;
              tmpTaxFreeUnit.Init;
              tmpTaxFreeUnit.TransferFields(TaxFreeUnit);
              tmpTaxFreeUnit.Insert;
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

