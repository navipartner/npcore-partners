codeunit 6059935 "Hotkey Management"
{
    // NPR4.13/RA/20150724  CASE 210079 Added function CheckHotkeySupportSetup

    SingleInstance = true;

    trigger OnRun()
    begin
        StartListen();
    end;

    var
        Initialized: Boolean;
        HotkeyListener: Page "Hotkey Listener";

    procedure HotkeyPressed(ControlPressed: Boolean;AltPressed: Boolean;ShiftPressed: Boolean;"Key": Text[1])
    var
        Hotkey: Record Hotkey;
        HotkeyPattern: Text;
    begin
        HotkeyPattern := BuildHotkeyPattern(ControlPressed,AltPressed,ShiftPressed,Key);

        Hotkey.SetRange(Hotkey,HotkeyPattern);

        if Hotkey.FindSet then repeat
          case Hotkey."Hotkey Action" of
            Hotkey."Hotkey Action"::Object      : LaunchObject(Hotkey);
            Hotkey."Hotkey Action"::Application : LaunchApplication(Hotkey);
          end;
        until Hotkey.Next = 0;
    end;

    procedure StartListen()
    begin
        if not Initialized then begin
          HotkeyListener.Run();
          Initialized   := true;
        end;
    end;

    procedure StopListen()
    begin
        HotkeyListener.Stop();
    end;

    procedure LaunchApplication(Hotkey: Record Hotkey)
    var
        [RunOnClient]
        DotNetProcess: DotNet Process;
    begin
        if CopyStr(Hotkey."Application Path",1,4) = 'http' then begin
          DotNetProcess := DotNetProcess.Process();
          DotNetProcess.StartInfo.UseShellExecute := false;
          DotNetProcess.StartInfo.FileName        := Hotkey."Application Path";
          DotNetProcess.Start('rundll32.exe', 'dfshim.dll,ShOpenVerbApplication ' + Hotkey."Application Path");
        end else begin
          DotNetProcess := DotNetProcess.Process();
          DotNetProcess.StartInfo.UseShellExecute := false;
          DotNetProcess.StartInfo.FileName        := Hotkey."Application Path";
          DotNetProcess.Start();
        end;
    end;

    procedure LaunchObject(Hotkey: Record Hotkey)
    begin
        case Hotkey."Object Type" of
          Hotkey."Object Type"::Codeunit :
            CODEUNIT.Run(Hotkey."Object ID");
          Hotkey."Object Type"::Page :
            PAGE.Run(Hotkey."Object ID");
          Hotkey."Object Type"::Report :
            REPORT.Run(Hotkey."Object ID");
        end;
    end;

    procedure "-- Aux"()
    begin
    end;

    procedure BuildHotkeyPattern(ControlPressed: Boolean;AltPressed: Boolean;ShiftPressed: Boolean;"Key": Text[1]) Hotkey: Text
    begin
        if ControlPressed then
          Hotkey += '+Ctrl';

        if AltPressed then
          Hotkey += '+Alt';

        if ShiftPressed then
          Hotkey += '+Shift';

        if Key = '' then Error('Invalid format.');

        Hotkey += '+' + Key;

        Hotkey := CopyStr(Hotkey,2);
    end;

    procedure FormatHotkey(HotkeyIn: Text) Hotkey: Text
    var
        String: Codeunit "String Library";
        ControlPressed: Boolean;
        AltPressed: Boolean;
        ShiftPressed: Boolean;
        Itt: Integer;
        KeyActivate: Text[1];
        "Key": Text[10];
    begin
        String.Construct(DelChr(HotkeyIn,'=',' '));

        for Itt := 1 to String.CountOccurences('+') + 1 do begin
          Key := String.SelectStringSep(Itt,'+');
          case Key of
            'Ctrl'    : ControlPressed := true;
            'Control' : ControlPressed := true;
            'Alt'     : AltPressed     := true;
            'Shift'   : ShiftPressed   := true;
          else
            if StrLen(Key) > 1 then
              Error('Illegal format.')
            else
              KeyActivate := Key;
          end;
        end;

        Hotkey := BuildHotkeyPattern(ControlPressed,AltPressed,ShiftPressed,KeyActivate);
    end;

    procedure CheckHotkeySupportSetup()
    var
        Hotkey: Record Hotkey;
        RetailSetup: Record "Retail Setup";
    begin
        //-NPR4.13
        RetailSetup.Get;
        if RetailSetup."Hotkey for Louislane" = '' then begin
          if Hotkey.Get('LOUISLANE') then begin
            RetailSetup."Hotkey for Louislane" := Hotkey.Code;
            RetailSetup.Modify;
          end else begin
            Hotkey.Code               := 'LOUISLANE';
            Hotkey.Description        := 'Louislane';
            Hotkey.Hotkey             := 'Ctrl+Alt+Shift+I';
            Hotkey."Hotkey Action"    := Hotkey."Hotkey Action"::Application;
            Hotkey."Object Type"      := Hotkey."Object Type"::Page;
            Hotkey."Object ID"        := 30;
            Hotkey."Application Path" := 'https://nav.npkhosting.dk/Software/LouisLane/LouisLane.application';
            Hotkey.Insert;
            RetailSetup."Hotkey for Louislane" := Hotkey.Code;
            RetailSetup.Modify;
          end;
        end;

        if RetailSetup."Hotkey for Request Commando" = '' then begin
          if Hotkey.Get('REQCOMM') then begin
            RetailSetup."Hotkey for Request Commando" := Hotkey.Code;
            RetailSetup.Modify;
          end else begin
            Hotkey.Code               := 'REQCOMM';
            Hotkey.Description        :='Request Commando';
            Hotkey.Hotkey             := 'Ctrl+Alt+Shift+S';
            Hotkey."Hotkey Action"    := Hotkey."Hotkey Action"::Application;
            Hotkey."Application Path" := 'https://nav.npkhosting.dk/Software/RequestCommando/RequestCommando.Application';
            Hotkey.Insert;
            RetailSetup."Hotkey for Request Commando" := Hotkey.Code;
            RetailSetup.Modify;
          end;
        end;
        //+NPR4.13
    end;
}

