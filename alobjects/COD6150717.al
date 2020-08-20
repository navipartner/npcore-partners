codeunit 6150717 "POS Front End Keeper"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        POSSession: Codeunit "POS Session";
        Framework: Interface "Framework Interface";
        FrontEnd: Codeunit "POS Front End Management";
        Initialized: Boolean;

    procedure Initialize(FrameworkIn: Interface "Framework Interface"; FrontEndIn: Codeunit "POS Front End Management"; POSSessionIn: Codeunit "POS Session")
    begin
        FrontEnd := FrontEndIn;
        Framework := FrameworkIn;
        POSSession := POSSessionIn;
        Initialized := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150700, 'OnDetectFramework', '', false, false)]
    local procedure DetectFrontEnd(var FrontEndOut: Codeunit "POS Front End Management"; var POSSessionOut: Codeunit "POS Session"; var Active: Boolean)
    begin
        FrontEndOut := FrontEnd;
        POSSessionOut := POSSession;
        Active := Initialized;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150704, 'OnDetectFramework', '', false, false)]
    local procedure DetectFramework(var FrameworkOut: Interface "Framework Interface"; var POSSessionOut: Codeunit "POS Session"; var Handled: Boolean)
    begin
        FrameworkOut := Framework;
        POSSessionOut := POSSession;
        if Initialized then
            Handled := true;
    end;
}

