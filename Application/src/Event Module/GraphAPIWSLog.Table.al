table 6014596 "NPR GraphAPI WS Log"
{
    Caption = 'GraphAPI WS Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Call No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Call No';
            AutoIncrement = true;
        }
        field(10; "Call Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Call Date Time';
        }
        field(20; "Call Description"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Call Description';
        }
        field(30; "Call Request"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Call Request';
        }
        field(40; "Call Response"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Call Response';
        }
        field(50; "Call URL"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Call URL';
        }
        field(60; "E-Mail"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'E-Mail';
        }

    }

    keys
    {
        key(PK; "Call No.")
        {
            Clustered = true;
        }
    }



    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;


    procedure SetCallRequest(NewCallRequest: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Call Request");
        "Call Request".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewCallRequest);
        Modify();
    end;

    procedure GetCallRequest(): Text
    var
        InStream: InStream;
        TypeHelper: Codeunit "Type Helper";
    begin
        CalcFields("Call Request");
        "Call Request".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    procedure SetCallResponse(NewRequest: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Call Response");
        "Call Response".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewRequest);
        Modify();
    end;

    procedure GetCallResponse(): Text
    var
        InStream: InStream;
        TypeHelper: Codeunit "Type Helper";
    begin
        CalcFields("Call Response");
        "Call Response".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    procedure LogCall(LogDescription: Text; CallRequest: Text; CallResponse: Text; CallURL: Text; Email: Text[250])
    var
        Log: Record "NPR GraphAPI WS Log";
    begin
        Log.Init();
        Log."Call Date Time" := CurrentDateTime();
        Log."Call Description" := CopyStr(LogDescription, 1, MaxStrLen(Log."Call Description"));
        Log."Call URL" := CopyStr(CallURL, 1, MaxStrLen(Log."Call URL"));
        Log."E-Mail" := Email;
        Log.Insert(true);
        Log.SetCallRequest(CallRequest);
        Log.SetCallResponse(CallResponse);
    end;

    procedure DeleteWebServiceLog()
    var
        WSLog: Record "NPR GraphAPI WS Log";
        ConfirmQst: Label 'This action will delete all records. Do you want to continue?';
    begin
        if Confirm(ConfirmQst, true) then begin
            WSLog.Reset();
            WSLog.DeleteAll();
        end;
    end;


    procedure DownloadRequest()
    var
        istream: InStream;
        FileName: Text;
        FileDialogTitleLbl: Label 'Save File';
        FileDialogFilterTok: Label 'JSON File (*.json)|*.json';
    begin
        CalcFields("Call Request");
        "Call Request".CreateInStream(istream, TextEncoding::UTF8);
        DownloadFromStream(istream, FileDialogTitleLbl, '', FileDialogFilterTok, FileName);
    end;

    procedure DownloadResponse()
    var
        istream: InStream;
        FileName: Text;
        FileDialogTitleLbl: Label 'Save File';
        FileDialogFilterTok: Label 'JSON File (*.json)|*.json';
    begin
        CalcFields("Call Response");
        "Call Response".CreateInStream(istream, TextEncoding::UTF8);
        DownloadFromStream(istream, FileDialogTitleLbl, '', FileDialogFilterTok, FileName);
    end;

}
