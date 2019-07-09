page 6059888 "Npm Pages"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager

    Caption = 'Page Manager - Pages';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Npm Page";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("Page ID";"Page ID")
                {
                }
                field("Page Name";"Page Name")
                {
                }
                field("Npm Enabled";"Npm Enabled")
                {
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
            part(Views;"Npm Page Subform")
            {
                ShowFilter = false;
                SubPageLink = "Page ID"=FIELD("Page ID");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Load Pages")
            {
                Caption = 'Load Pages';
                Image = RefreshPlanningLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NpmMetadataMgt: Codeunit "Npm Metadata Mgt.";
                begin
                    NpmMetadataMgt.LoadNpmPages();
                    CurrPage.Update(false);
                end;
            }
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
        area(creation)
        {
            action("Show Metadata (Original)")
            {
                Caption = 'Show Metadata (Original)';
                Image = XMLFile;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                begin
                    ShowMetadata(true);
                end;
            }
            action("Show Metadata (Latest)")
            {
                Caption = 'Show Metadata (Latest)';
                Image = XMLFile;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                begin
                    ShowMetadata(false);
                end;
            }
        }
    }

    var
        Text000: Label 'No metadata';

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
}

