codeunit 6014615 "NPR TaxFree GBI2 GetBCountries"
{
    Access = Internal;
    // Codeunit is intended to be scheduled for NAS for customers running a Global Blue I2 Tax Free integration, for weekly execution.
    // It retrieves and stores a list of blocked enduser countries for use in the I2 integration flow.
    trigger OnRun()
    var
        TaxFreeRequest: Record "NPR Tax Free Request";
        GlobalBlueHandler: Codeunit "NPR Tax Free GB I2";
        TempTaxFreeUnit: Record "NPR Tax Free POS Unit" temporary;
    begin
        if not FindUniqueCountryTaxFreeUnits(TempTaxFreeUnit) then
            Error(Error_MissingParams);

        TempTaxFreeUnit.FindSet();
        repeat
            TaxFreeRequest.Init();
            TaxFreeRequest."Request Type" := 'GET_BLOCKED_COUNTRIES';
            TaxFreeRequest."POS Unit No." := TempTaxFreeUnit."POS Unit No.";
            TaxFreeRequest.Mode := TempTaxFreeUnit.Mode;
            TaxFreeRequest."Timeout (ms)" := 300 * 1000;
            TaxFreeRequest."Time Start" := Time;
            TaxFreeRequest."Date Start" := Today();

            GlobalBlueHandler.InitializeHandler(TaxFreeRequest);
            GlobalBlueHandler.DownloadBlockedCountries(TaxFreeRequest);
            Clear(TaxFreeRequest);
            Clear(GlobalBlueHandler);
        until TempTaxFreeUnit.Next() = 0;
    end;

    var
        Error_MissingParams: Label 'No valid handler parameters found';

    local procedure FindUniqueCountryTaxFreeUnits(var tmpTaxFreeUnit: Record "NPR Tax Free POS Unit" temporary): Boolean
    var
        GlobalBlueParameters: Record "NPR Tax Free GB I2 Param.";
        TaxFreeUnit: Record "NPR Tax Free POS Unit";
        TempInteger: Record "Integer" temporary;
    begin
        TaxFreeUnit.SetRange("Handler ID Enum", TaxFreeUnit."Handler ID Enum"::GLOBALBLUE_I2);
        TaxFreeUnit.FindSet();
        repeat
            GlobalBlueParameters.SetFilter("Shop ID", '<>%1', '');
            GlobalBlueParameters.SetFilter("Desk ID", '<>%1', '');
            GlobalBlueParameters.SetFilter("Shop Country Code", '<>%1', 0);
            GlobalBlueParameters.SetRange("Tax Free Unit", TaxFreeUnit."POS Unit No.");
            if GlobalBlueParameters.FindFirst() then
                if not TempInteger.Get(GlobalBlueParameters."Shop Country Code") then begin
                    TempInteger.Init();
                    TempInteger.Number := GlobalBlueParameters."Shop Country Code";
                    TempInteger.Insert();
                    tmpTaxFreeUnit.Init();
                    tmpTaxFreeUnit.TransferFields(TaxFreeUnit);
                    tmpTaxFreeUnit.Insert();
                end;
        until TaxFreeUnit.Next() = 0;

        exit(not tmpTaxFreeUnit.IsEmpty());
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

