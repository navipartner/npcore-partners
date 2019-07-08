codeunit 6014425 "Nav App Mgt"
{
    // #300683/JDH /20180202 CASE 300683 Function to use in NAV 2018


    trigger OnRun()
    begin
    end;

    procedure NavAPP_IsInstalling(): Boolean
    begin
        //From 2017 its possible to use NAVAPP.ISINSTALLING
        exit(NAVAPP.IsInstalling);
    end;
}

