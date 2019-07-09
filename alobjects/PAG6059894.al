page 6059894 "Npm View Pages"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager

    Caption = 'Mandatory Pages';
    PageType = List;
    SourceTable = "Npm Page";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Page ID";"Page ID")
                {
                }
                field("Page Name";"Page Name")
                {
                }
                field(ShowMandatory;ShowMandatory)
                {
                    Caption = 'Show Mandatory Fields';

                    trigger OnValidate()
                    begin
                        ValidateShowFields();
                    end;
                }
                field(ShowCaption;ShowCaption)
                {
                    Caption = 'Show Field Captions';

                    trigger OnValidate()
                    begin
                        ValidateShowFields();
                    end;
                }
                field("Source Table No.";"Source Table No.")
                {
                    Visible = false;
                }
                field("Source Table Name";"Source Table Name")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Run)
            {
                Caption = 'Run';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    PAGE.Run("Page ID");
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetShowFields();
    end;

    var
        Text000: Label 'No metadata';
        NpmView: Record "Npm View";
        ShowMandatory: Boolean;
        ShowCaption: Boolean;

    local procedure ShowMetadata(ShowOriginal: Boolean)
    var
        TempBlob: Record TempBlob temporary;
        FileMgt: Codeunit "File Management";
        StreamReader: DotNet npNetStreamReader;
        InStr: InStream;
        Path: Text;
        Content: Text;
    begin
        if ShowOriginal then begin
          if not "Original Metadata".HasValue then begin
            Message(Text000);
            exit;
          end;
          CalcFields("Original Metadata");
          TempBlob.Blob := "Original Metadata";
        end else begin
          if not "Latest Metadata".HasValue then begin
            Message(Text000);
            exit;
          end;
          CalcFields("Latest Metadata");
          TempBlob.Blob := "Latest Metadata";
        end;

        if CurrentClientType <> CLIENTTYPE::Windows then begin
          TempBlob.Blob.CreateInStream(InStr);
          StreamReader := StreamReader.StreamReader(InStr);
          Content := StreamReader.ReadToEnd();
          Message(Content);
          exit;
        end;

        Path := FileMgt.BLOBExport(TempBlob,TemporaryPath + "Page Name" + '.xml',false);
        RunProcess('iexplore.exe',Path,false);
        Sleep(500);
        FileMgt.DeleteClientFile(Path);
    end;

    local procedure RunProcess(Filename: Text;Arguments: Text;Modal: Boolean)
    var
        [RunOnClient]
        Process: DotNet npNetProcess;
        [RunOnClient]
        ProcessStartInfo: DotNet npNetProcessStartInfo;
    begin
        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(Filename,Arguments);
        Process := Process.Start(ProcessStartInfo);
        if Modal then
          Process.WaitForExit();
    end;

    procedure SetNpmView(NewNpmView: Record "Npm View")
    var
        NpmPage: Record "Npm Page";
    begin
        NpmView := NewNpmView;

        Clear(Rec);
        DeleteAll;

        NpmPage.SetRange("Source Table No.",NpmView."Table No.");
        if NpmPage.IsEmpty then
          exit;

        NpmPage.FindSet;
        repeat
          Rec.Init;
          Rec := NpmPage;
          Rec.Insert;
        until NpmPage.Next = 0;
        Clear(Rec);
    end;

    local procedure SetShowFields()
    var
        NpmPageView: Record "Npm Page View";
    begin
        ShowMandatory := false;
        ShowCaption := false;

        if not NpmPageView.Get("Page ID",NpmView.Code) then
          exit;
        ShowMandatory := NpmPageView."Show Mandatory Fields";
        ShowCaption := NpmPageView."Show Field Captions";
    end;

    local procedure ValidateShowFields()
    var
        NpmPageView: Record "Npm Page View";
    begin
        if not (ShowMandatory or ShowCaption) then begin
          if NpmPageView.Get("Page ID",NpmView.Code) then
            NpmPageView.Delete(true);

          exit;
        end;

        if not NpmPageView.Get("Page ID",NpmView.Code) then begin
          NpmPageView.Init;
          NpmPageView."Page ID" := "Page ID";
          NpmPageView."View Code" := NpmView.Code;
          NpmPageView.Validate("Show Mandatory Fields",ShowMandatory);
          NpmPageView.Validate("Show Field Captions",ShowCaption);
          NpmPageView.Insert(true);
        end else begin
          NpmPageView.Validate("Show Mandatory Fields",ShowMandatory);
          NpmPageView.Validate("Show Field Captions",ShowCaption);
          NpmPageView.Modify(true);
        end;
    end;
}

