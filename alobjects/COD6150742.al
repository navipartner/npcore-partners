codeunit 6150742 "POS Cancel Sale Key Bind"
{
    // NPR5.38/MHA /20180119  CASE 295800 Object created - POS KeyboardBindings
    // NPR5.40/VB  /20180306 CASE 306347 Refactored InvokeWorkflow call.
    // NPR5.48/TJ  /20180806 CASE 323835 Recoded entire codeunit and renamed to reflect Cancel Sale specific action


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Sale was canceled %1';

    [EventSubscriber(ObjectType::Codeunit, 6150744, 'OnDiscoverKeyboardBindings', '', true, true)]
    local procedure Discover(var POSKeyboardBindingSetup: Record "POS Keyboard Binding Setup")
    begin
        //-NPR5.48 [323835]
        //KeyboardBindings.Add('Esc');
        POSKeyboardBindingSetup.Init;
        POSKeyboardBindingSetup."Action Code" := GetActionCode();
        POSKeyboardBindingSetup."Key Bind" := GetKeyCode();
        POSKeyboardBindingSetup.Description := GetKeyDescription();
        POSKeyboardBindingSetup."Default Key Bind" := GetKeyCode();
        POSKeyboardBindingSetup.Enabled := true;
        POSKeyboardBindingSetup.Insert();
        //+NPR5.48 [323835]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150744, 'OnInvokeKeyPress', '', false, false)]
    local procedure OnKeyPress(KeyPress: Text;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        POSView: DotNet View0;
        POSViewType: DotNet ViewType0;
        POSKeyboardBindingMgt: Codeunit "POS Keyboard Binding Mgt.";
    begin
        //-NPR5.48 [323835]
        /*
        CASE LOWERCASE(KeyPress) OF
          'esc':
            BEGIN
              OnKeyPressEsc(POSSession,FrontEnd);
              Handled := TRUE;
            END;
        END;
        */
        if not POSKeyboardBindingMgt.KeyboardBindingEnabled(GetActionCode(),KeyPress,GetKeyCode()) then
          exit;
        POSSession.GetCurrentView(POSView);
        case Format(POSView.Type) of
          Format(POSViewType.Sale):
            //-NPR5.40 [306347]
            //CancelSale(FrontEnd);
            CancelSale(FrontEnd,POSSession);
            //+NPR5.40 [306347]
          Format(POSViewType.Payment):
            POSSession.ChangeViewSale();
        end;
        //+NPR5.48 [323835]

    end;

    local procedure OnKeyPressEsc(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        POSView: DotNet View0;
        POSViewType: DotNet ViewType0;
    begin
        //-NPR5.48 [323835]
        /* not needed as entire codeunit is for Cancel Sale process, for new keybind, new codeunit will be created
        POSSession.GetCurrentView(POSView);
        CASE FORMAT(POSView.Type) OF
          FORMAT(POSViewType.Sale):
            //-NPR5.40 [306347]
            //CancelSale(FrontEnd);
            CancelSale(FrontEnd,POSSession);
            //+NPR5.40 [306347]
          FORMAT(POSViewType.Payment):
            POSSession.ChangeViewSale();
        END;
        */
        //+NPR5.48 [323835]

    end;

    local procedure CancelSale(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session")
    var
        SaleLinePOS: Record "Sale Line POS";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        Context: DotNet JObject;
        POSJavaScriptInterface: Codeunit "POS JavaScript Interface";
        POSAction: Record "POS Action";
    begin
        //-NPR5.40 [306347]
        //POSAction.GET('CANCEL_POS_SALE');
        if not POSSession.RetrieveSessionAction('CANCEL_POS_SALE',POSAction) then
          POSAction.Get('CANCEL_POS_SALE');
        //+NPR5.40 [306347]
        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure GetActionCode(): Text
    begin
        //-NPR5.48 [323835]
        exit('CANCELSALE');
        //+NPR5.48 [323835]
    end;

    local procedure GetKeyCode(): Text
    begin
        //-NPR5.48 [323835]
        exit('Escape');
        //+NPR5.48 [323835]
    end;

    local procedure GetKeyDescription(): Text
    begin
        //-NPR5.48 [323835]
        exit('Cancels current sale');
        //+NPR5.48 [323835]
    end;
}

