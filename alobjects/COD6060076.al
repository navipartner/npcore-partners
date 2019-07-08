codeunit 6060076 "Upgrade: NPR Pre-Map"
{
    // NPR5.29/BR /20161205  CASE 258697 Upgrade Codeunit Created

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [UpgradePerCompany]
    procedure UpgradeDataExchangeMapping()
    var
        DataExchMapping: Record "Data Exch. Mapping";
    begin
        with DataExchMapping do begin
          Reset;
          if FindSet then repeat
            if "Pre-Mapping Codeunit" = CODEUNIT::"Pre-map Incoming Purch. Doc" then begin
              "Pre-Mapping Codeunit" := CODEUNIT::"NPR Pre-map Incoming Purch Doc";
              Modify;
            end;
          until Next =  0;
        end;
    end;
}

