codeunit 6014482 "NPR Service Calculation"
{

    trigger OnRun()
    begin
        tempRetailList.Chosen := true;
        tempRetailList.Choice := 'ECLUBSMS';
        //tempRetailList.Choice := 'CVR';
        tempRetailList.Value := Format(Round(1234.5678, 0.01) * 100, 0, 1);
        //tempRetailList.Value := 'dfdf';
        //CODEUNIT.RUN(CODEUNIT::"NP Service Process", tempRetailList);
        if CODEUNIT.Run(CODEUNIT::"NPR Service Process", tempRetailList) then
            Message('Success CU')
        else
            Message('Some errors CU');

        if tempRetailList.Chosen then
            Message('Chosen TRUE')
        else
            Message('Chosen FALSE');
    end;

    var
        result: Boolean;
        tempRetailList: Record "NPR Retail List" temporary;

    procedure useService(service: Text[30]): Boolean
    begin
        result := false;
        tempRetailList.Init();
        tempRetailList.Choice := service;

        /*
        IF CODEUNIT.RUN(CODEUNIT::"NP Service Process", tempRetailList) THEN
          IF tempRetailList.Chosen THEN
            result := TRUE;
        */

        tempRetailList.Chosen := true;
        if CODEUNIT.Run(CODEUNIT::"NPR Service Process", tempRetailList) then;

        if tempRetailList.Chosen then
            result := true;
        exit(result);

    end;

    procedure useServiceAmount(service: Text[30]; p_amount: Decimal): Boolean
    begin
        result := false;
        tempRetailList.Init();
        tempRetailList.Choice := service;
        tempRetailList.Value := Format(Round(p_amount, 0.01) * 100, 0, 1);

        tempRetailList.Chosen := true;
        if CODEUNIT.Run(CODEUNIT::"NPR Service Process", tempRetailList) then;

        if tempRetailList.Chosen then
            result := true;
        exit(result);
    end;
}

