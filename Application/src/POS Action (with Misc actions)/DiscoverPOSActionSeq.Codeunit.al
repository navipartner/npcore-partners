codeunit 6150737 "NPR Discover POSAction Seq."
{
    // NPR5.53/VB  /20190917  CASE 362777 Support for workflow sequencing (configuring/registering "before" and "after" workflow sequences that execute before or after another workflow)
    //                                    This codeunit is used only for the purpose of IF CODEUNIT.RUN construct.


    trigger OnRun()
    begin
        Sequence.RunActionSequenceDiscovery();
    end;

    var
        Sequence: Record "NPR POS Action Sequence";
}

