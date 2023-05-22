codeunit 6150983 "NPR Dim. Handling Modifier"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

#IF NOT (BC17 or BC18 or BC19 or BC20 or BC2100 or BC2101 or BC2102 or BC2103 or BC2104)
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeConfirmKeepExistingDimensions', '', true, false)]  //First appears in BC21.5
    local procedure SalesHeader_DeclineKeepExistingDimensions(var Confirmed: Boolean; var IsHandled: Boolean)
    begin
        Confirmed := false;
        IsHandled := true;
    end;
#ENDIF
}