codeunit 6014541 "NPR RP BixolonDisp Device Lib."
{
    // Bixolon Disp. Command Library Library.
    //  Work started by Nicolai Esbensen.
    //  Contributions providing function interfaces for valid
    //  Bixolon Display escape sequences are welcome. Functionality
    //  for other displays should be put in a library on its own.
    // 
    //  All functions write ESC code to a string buffer which can
    //  be sent to a display or stored to a file.
    // 
    //  Current functions and their purpose are listed below.
    // --------------------------------------------------------
    // 
    // ShortHandFunctions
    //  "PrintText(Text : Text[100];FontType : Text[10];Bold : Boolean;UnderLine : Boolean;DoubleStrike : Boolean;Align : Integer)"
    //   Adds the text variable to the buffer, applying the font style given as arguments.
    // 
    // ---------------------------------------------------------------------------------
    // Base Functions
    //  Writes standard functional sequences to the buffer. All with reference to the
    //  manual.
    // 
    // ---------------------------------------------------------------------------------
    // Test Functions
    //  Functions for testing the functionality implemented in this library.
    // 
    // NPR4.15/MMV/20150731 CASE 218278 Encode print with codepage 437 (Bixolon BCD-1100 default)
    // NPR4.15/MMV/20151005 CASE 223893 Added methods:
    //                                    GetPrintBuffer()
    //                                    SetPrintBuffer()
    // NPR5.20/MMV/20160225 CASE 233229 Moved print method logic away from device codeunits.
    //                                  Also removed old case comments, along with small cleanup/renaming.
    // NPR5.23/MMV/20160503 CASE 237189 Clear PrintBuffer on Init.
    // NPR5.32/MMV /20170324 CASE 241995 Retail Print 2.0

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        TempPattern: Text[50];
        ESC: Codeunit "NPR RP Escape Code Library";
        PrintBuffer: Text;

    local procedure "// Interface implementation"()
    begin
    end;

    local procedure DeviceCode(): Text
    begin
        exit('DISPLAYBIXOLON');
    end;

    procedure IsThisDevice(Text: Text): Boolean
    begin
        exit(StrPos(UpperCase(Text), DeviceCode) > 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnInitJob', '', false, false)]
    local procedure OnInitJob(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        Init();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnPrintData', '', false, false)]
    local procedure OnPrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    begin
        PrintText(POSPrintBuffer.Text);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnGetPageWidth', '', false, false)]
    local procedure OnGetPageWidth(FontFace: Text[30]; var Width: Integer)
    begin
        Width := GetPageWidth(FontFace);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnGetTargetEncoding', '', false, false)]
    local procedure OnGetTargetEncoding(var TargetEncoding: Text)
    begin
        TargetEncoding := 'IBM437';
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnGetPrintBytes', '', false, false)]
    local procedure OnGetPrintBytes(var PrintBytes: Text)
    begin
        PrintBytes := PrintBuffer;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnSetPrintBytes', '', false, false)]
    local procedure OnSetPrintBytes(var PrintBytes: Text)
    begin
        PrintBuffer := PrintBytes;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnBuildDeviceList', '', false, false)]
    local procedure OnBuildDeviceList(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Value := DeviceCode();
        tmpRetailList.Choice := DeviceCode();
        tmpRetailList.Insert();
    end;

    local procedure "// ShortHandFunctions"()
    begin
    end;

    procedure Init()
    begin
        Clear(PrintBuffer);
        InitializePrinter;
    end;

    procedure PrintText(Text: Text)
    begin
        AddTextToBuffer(Text);
    end;

    local procedure InitializePrinter()
    begin
        TempPattern := 'ESC @ ESC = 02 ESC R EOT';
        AddToBuffer(TempPattern);
    end;

    procedure GetPrintBytes(): Text
    begin
        exit(PrintBuffer);
    end;

    procedure SetPrintBytes(PrintBytes: Text)
    begin
        PrintBuffer := PrintBytes;
    end;

    local procedure "// Base Functions"()
    begin
    end;

    procedure HorizontalTab()
    begin
        AddToBuffer('HT');
    end;

    procedure LineFeed()
    begin
        AddToBuffer('LF');
    end;

    procedure FormFeed()
    begin
        AddToBuffer('FF');
    end;

    procedure CarriageReturn()
    begin
        AddToBuffer('CR');
    end;

    procedure Cancel()
    begin
        AddToBuffer('CAN');
    end;

    local procedure "// Info Functions"()
    begin
    end;

    procedure GetPageWidth(FontFace: Text[30]) Width: Integer
    begin
        Width := 20;
    end;

    local procedure "// Aux Functions"()
    begin
    end;

    local procedure AddToBuffer(Text: Text)
    begin
        ESC.WriteSequenceToBuffer(Text, PrintBuffer);
    end;

    local procedure AddCharToBuffer(CharCode: Integer)
    begin
        PrintBuffer := PrintBuffer + Format(CharCode);
    end;

    local procedure AddTextToBuffer(Text: Text)
    begin
        PrintBuffer := PrintBuffer + Text;
    end;

    local procedure "// Test Functions"()
    begin
    end;

    local procedure PrintToDisplay()
    begin
        AddTextToBuffer('12345678901234567890');
        CarriageReturn;
        AddTextToBuffer('01234567890123456789');
    end;
}

