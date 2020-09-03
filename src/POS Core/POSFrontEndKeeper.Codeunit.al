codeunit 6150717 "NPR POS Front End Keeper"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        POSSession: Codeunit "NPR POS Session";
        Framework: Interface "NPR Framework Interface";
        FrontEnd: Codeunit "NPR POS Front End Management";
        Initialized: Boolean;

    procedure Initialize(FrameworkIn: Interface "NPR Framework Interface"; FrontEndIn: Codeunit "NPR POS Front End Management"; POSSessionIn: Codeunit "NPR POS Session")
    begin
        FrontEnd := FrontEndIn;
        Framework := FrameworkIn;
        POSSession := POSSessionIn;
        Initialized := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150700, 'OnDetectFramework', '', false, false)]
    local procedure DetectFrontEnd(var FrontEndOut: Codeunit "NPR POS Front End Management"; var POSSessionOut: Codeunit "NPR POS Session"; var Active: Boolean)
    begin
        FrontEndOut := FrontEnd;
        POSSessionOut := POSSession;
        Active := Initialized;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150704, 'OnDetectFramework', '', false, false)]
    local procedure DetectFramework(var FrameworkOut: Interface "NPR Framework Interface"; var POSSessionOut: Codeunit "NPR POS Session"; var Handled: Boolean)
    begin
        FrameworkOut := Framework;
        POSSessionOut := POSSession;
        if Initialized then
            Handled := true;
    end;
}

