page 6150771 "NPR POS HTML Disp. Prof. Card"
{
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR POS HTML Disp. Prof.";
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'HTML Display Profile';
#IF NOT BC17
    AboutTitle = 'HTML Display Profile';
    AboutText = 'This page describes a HTML display profile, which can be used for multiple POS Units.';
#ENDIF

    layout
    {
        area(Content)
        {
            group(Configuration)
            {
                field("Profile Code"; Rec."Code")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Code';
                    ToolTip = 'Specifies the unique code identifying the profile.';
#IF NOT BC17
                    AboutTitle = 'Code';
                    AboutText = 'Specifies a unique code to identify the profile.';
#ENDIF
                }
                field(HTML; Rec."HTML Blob".HasValue())
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'HTML File';
                    ToolTip = 'Specifies if an HTML file is uploaded. Upload HTML via the ''Upload File'' action';
#IF NOT BC17
                    AboutTitle = 'HTML File';
                    AboutText = 'Specifies if an HTML file is uploaded. Upload HTML via the ''Upload File'' action';
#ENDIF
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Description';
                    ToolTip = 'Speccifies the description of the profile, to help distinguish between profiles.';
#IF NOT BC17
                    AboutTitle = 'Description';
                    AboutText = 'Speccifies the description of the profile, to help distinguish between profiles.';
#ENDIF
                }
                field("Content Lines Code"; Rec."Display Content Code")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Display Content Code';
                    ToolTip = 'Specifies the media the HTML needs to display.';
#IF NOT BC17
                    AboutTitle = 'Content Lines';
                    AboutText = 'Specifies the media the HTML needs to display.';
#ENDIF
                }
                field("Ex. VAT"; Rec."Ex. VAT")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Price ex. VAT';
                    ToolTip = 'Specifies if VAT should be excluded on the receipt';
#IF NOT BC17
                    AboutTitle = 'Ex. VAT';
                    AboutText = 'Specifies if VAT should be excluded on the receipt';
#ENDIF
                }
            }
            group("Input Options")
            {
                field("Costumer Input Option: Money Back"; Rec."CIO: Money Back")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Costumer Input Option: Money Back';
                    ToolTip = 'Specifies the costumer input options.';
#IF NOT BC17
                    AboutTitle = 'Costumer Input Option: Money Back';
                    AboutText = 'Specifies the costumer input options.';
#ENDIF
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Upload HTML")
            {
                ApplicationArea = NPRRetail;
                Image = Import;
                ToolTip = 'Upload HTML to be used for Costumer Display.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    fileName: Text;
                    inStream: InStream;
                    outStream: OutStream;
                begin
                    if (UploadIntoStream('', '', '', fileName, inStream)) then begin
                        if (not filename.EndsWith('.html')) then begin
                            Message('please upload an html file');
                            exit;
                        end;
                        Rec."HTML Blob".CreateOutStream(outStream);
                        CopyStream(outStream, inStream);
                        Rec.Modify();
                    end else begin
                        Message('Upload failed');
                    end;
                end;
            }
            action("Download HTML")
            {
                ApplicationArea = NPRRetail;
                Image = Export;
                ToolTip = 'Download HTML to be used for Costumer Display.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    fileName: Text;
                    inStream: InStream;
                begin
                    filename := Rec."Code" + '-profile.html';
                    if (Rec."HTML Blob".HasValue()) then begin
                        Rec.CalcFields("HTML Blob");
                        Rec."HTML Blob".CreateInStream(inStream);
                        DownloadFromStream(inStream, 'Download html', '', '.html', filename);
                    end else begin
                        Message('Html field does not have a value');
                    end;

                end;
            }
        }
        area(Navigation)
        {
            action("POS Device Display")
            {
                Caption = 'POS Unit Display';
                Image = Administration;
                RunObject = Page "NPR POS Unit Display";
                ToolTip = 'Set Unit specific info for POS Display Profile';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
            action("POS Unit List")
            {
                Caption = 'POS Unit List';
                Image = Administration;
                RunObject = Page "NPR POS Unit List";
                ToolTip = 'Go to POS Unit list';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
        }

    }
}