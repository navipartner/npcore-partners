codeunit 6014525 "DotNet File Library"
{
    SingleInstance = true;

    trigger OnRun()
    var
        This: Codeunit "DotNet File Library";
        Temp: Text;
    begin
        This.WRITEMODE(true);
        This.TEXTMODE(true);
        /*IF This.CREATE('\\tsclient\c\dankort\admin.txt') THEN BEGIN
          This.SEEK(This.LEN);
          This.WRITE('æ¢åæ¢åææÆ¥ÅÆÅ');
          This.CLOSE;
        END;*/
        TestInit;
        FileWrap.ERASE('C:\TEST.txt');
        
        //IF This.OPEN('\\tsclient\c\dankort\admin.txt') THEN BEGIN
        if This.OPEN('C:/admin.txt') then begin
          repeat
            This.READ(Temp);
            Message(Temp);
          until Temp = '';
        end;
        
        //IF This.CREATE('\\tsclient\c\dankort\Test.txt') THEN BEGIN
        if This.CREATE('C:/Test.txt') then begin
          This.SEEK(This.LEN);
          This.WRITE('TEST');
          This.CLOSE;
        end;
        
        
        This.OPEN('C:\tsclient\c\dankort\test.txt');
        This.OPEN('C:\tsclient\c\npk\inventory.txt');
        This.READ(Temp);
        if Temp <> 'TEST' then Error('AssertFailed');
        This.CLOSE;
        
        This.RENAME('C:\tsclient\c\dankort\test.txt','C:\tsclient\c\dankort\test2.txt');
        This.COPY('C:\tsclient\c\dankort\test2.txt','C:\tsclient\c\dankort\test3.txt');
        if not This.ERASE('C:\tsclient\c\dankort\test3.txt') then Message('Erro');
        //This.ERASE('\\tsclient\c\dankort\test2.txt');

    end;

    var
        [RunOnClient]
        FileWrap: DotNet npNetFileWrapper;
        IsInWriteMode: Boolean;
        IsInReadMode: Boolean;
        IsInTextmode: Boolean;
        IsQueryReplace: Boolean;
        IsFileOpen: Boolean;
        FileName: Text;
        IsInitialized: Boolean;
        this2: Integer;

    procedure OPEN(Name: Text[250]) Ok: Boolean
    begin
        TestInit;

        exit(FileWrap.OPEN(Name));
    end;

    procedure CREATE(Name: Text[1024]): Boolean
    begin
        TestInit;
        exit(FileWrap.CREATE(Name));
    end;

    procedure CLOSE()
    begin
        TestInit;
        FileWrap.CLOSE;
    end;

    procedure NAME() Name: Text[250]
    begin
        TestInit;
        Name := FileWrap.NAME
    end;

    procedure POS() Position: Integer
    begin
        TestInit;
        Position := FileWrap.POS;
    end;

    procedure LEN() Length: Integer
    begin
        TestInit;
        Length := FileWrap.LEN;
    end;

    procedure EOF() IsEOF: Boolean
    begin
        Error('EOF not implemented.');
    end;

    procedure READ(var Variable: Text): Integer
    var
        Bytes: DotNet npNetByte;
        i: Integer;
    begin
        TestInit;
        exit(FileWrap.READ(Variable,StrLen(Variable)));
    end;

    procedure WRITE(Value: Text[1024])
    var
        Byte: Byte;
    begin
        TestInit;
        FileWrap.WRITE(Value);
    end;

    procedure SEEK(Position: Integer)
    var
        [RunOnClient]
        SeekOriginDotNet: DotNet npNetSeekOrigin;
    begin
        TestInit;
        FileWrap.SEEK(Position);
    end;

    procedure TRUNC()
    begin
        Error('Unimplemented function TRUNK');
    end;

    procedure WRITEMODE(SetWriteMode: Boolean)
    begin
        TestInit;
        FileWrap.WRITEMODE(SetWriteMode);
    end;

    procedure TEXTMODE(SetTextmode: Boolean)
    begin
        TestInit;

        IsInTextmode := SetTextmode;
        FileWrap.TEXTMODE(SetTextmode);
    end;

    procedure QUERYREPLACE(SetQueryReplace: Boolean)
    begin
        TestInit;
        IsQueryReplace := SetQueryReplace;
        FileWrap.QUERYREPLACE(SetQueryReplace)
    end;

    procedure CREATEINSTREAM(InStream: InStream)
    begin
        TestInit;
        FileWrap.CREATEINSTREAM(InStream);
    end;

    procedure CREATEOUTSTREAM(OutStream: OutStream)
    begin
        TestInit;
        FileWrap.CREATEOUTSTREAM(OutStream);
    end;

    procedure CREATETEMPFILE() Ok: Boolean
    begin
        Error('Unimplemented function CREATETEMPFILE');
    end;

    procedure TestInit()
    begin
        if IsInitialized then exit;
        FileWrap      := FileWrap.FileWrapper();
        IsInitialized := true;
    end;

    procedure "---- StateLess functions --- replacing FILE"()
    begin
    end;

    procedure ERASE(Name: Text[1024]) Ok: Boolean
    begin
        TestInit;
        exit(FileWrap.ERASE(Name))
    end;

    procedure RENAME(FromName: Text[1024];ToName: Text[1024]) Ok: Boolean
    begin
        TestInit;
        exit(FileWrap.RENAME(FromName,ToName));
    end;

    procedure COPY(FromName: Text[1024];ToName: Text[1024]) Ok: Boolean
    begin
        TestInit;
        exit(FileWrap.COPY(FromName,ToName));
    end;

    procedure EXISTS(Name: Text[1024]) Ok: Boolean
    begin
        TestInit;
        exit(FileWrap.EXISTS(Name));
    end;
}

