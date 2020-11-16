codeunit 6150745 "NPR POS Session Finalizer"
{
    // NPR5.53/MMV /20200113 CASE 377284 Created object
    // 
    // Some modules act differently when a POSSession is currently active, since it can be used to invoke hardware directly via the POS page add-in without opening a new modal page.
    // To make the check more reliable for users switching between POS & role center, we subscribe and kill the POS instance if relevant.


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 9170, 'OnRoleCenterOpen', '', true, true)]
    local procedure OnRoleCenterOpen()
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        if not POSSession.GetSession(POSSession, false) then
            exit;

        POSSession.Destructor();
    end;
}

