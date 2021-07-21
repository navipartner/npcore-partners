codeunit 6150742 "NPR POS Cancel Sale Key Bind"
{

    [EventSubscriber(ObjectType::Codeunit, 6150744, 'OnDiscoverKeyboardBindings', '', true, true)]
    local procedure Discover(var POSKeyboardBindingSetup: Record "NPR POS Keyboard Bind. Setup")
    begin
        POSKeyboardBindingSetup.Init();
        POSKeyboardBindingSetup."Action Code" := GetActionCode();
        POSKeyboardBindingSetup."Key Bind" := GetKeyCode();
        POSKeyboardBindingSetup.Description := GetKeyDescription();
        POSKeyboardBindingSetup."Default Key Bind" := GetKeyCode();
        POSKeyboardBindingSetup.Enabled := true;
        POSKeyboardBindingSetup.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150744, 'OnInvokeKeyPress', '', false, false)]
    local procedure OnKeyPress(KeyPress: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSView: Codeunit "NPR POS View";
        POSKeyboardBindingMgt: Codeunit "NPR POS Keyboard Binding Mgt.";
    begin
        if not POSKeyboardBindingMgt.KeyboardBindingEnabled(GetActionCode(), KeyPress, GetKeyCode()) then
            exit;
        POSSession.GetCurrentView(POSView);
        case POSView.Type() of
            POSView.Type() ::Sale:
                CancelSale(FrontEnd, POSSession);
            POSView.Type() ::Payment:
                POSSession.ChangeViewSale();
        end;
    end;

    local procedure CancelSale(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        POSAction: Record "NPR POS Action";
    begin
        if not POSSession.RetrieveSessionAction('CANCEL_POS_SALE', POSAction) then
            POSAction.Get('CANCEL_POS_SALE');
        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure GetActionCode(): Text
    begin
        exit('CANCELSALE');
    end;

    local procedure GetKeyCode(): Text
    begin
        exit('Escape');
    end;

    local procedure GetKeyDescription(): Text
    begin
        exit('Cancels current sale');
    end;
}