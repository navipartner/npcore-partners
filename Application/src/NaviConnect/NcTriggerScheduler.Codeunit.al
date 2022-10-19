codeunit 6151521 "NPR Nc Trigger Scheduler"
{
    Access = Internal;

    [Obsolete('Task Queue module is about to be removed from NpCore so NC Trigger is also going to be removed.', 'BC 20 - Task Queue deprecating starting from 28/06/2022')]
    procedure GetParamName(): Text
    begin
        exit('NCTRIG');
    end;
}

