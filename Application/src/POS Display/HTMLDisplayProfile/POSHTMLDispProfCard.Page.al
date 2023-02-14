page 6150771 "NPR POS HTML Disp. Prof. Card"
{
    PageType = Card;
    ContextSensitiveHelpPage = 'retail/pos_profiles/howto/POS_HTMLDisplay_profile.html';
    UsageCategory = Administration;
    SourceTable = "NPR POS HTML Disp. Prof.";
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'HTML Display Profile';

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
                }
                field(HTML; Rec."HTML Blob".HasValue())
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'HTML File';
                    ToolTip = 'Specifies if an HTML file is uploaded. Upload HTML via the ''Upload File'' action';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Description';
                    ToolTip = 'Speccifies the description of the profile, to help distinguish between profiles.';
                }
                field("Content Lines Code"; Rec."Display Content Code")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Display Content Code';
                    ToolTip = 'Specifies the media the HTML needs to display.';
                }
                field("Ex. VAT"; Rec."Ex. VAT")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Price ex. VAT';
                    ToolTip = 'Specifies if VAT should be excluded on the receipt';
                }
                field("Receipt Item Description"; Rec."Receipt Item Description")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Receipt Item Description';
                    ToolTip = 'Specifies which description is used on the second display.';
                }
            }
            group("Input Options")
            {
                field("Costumer Input Option: Money Back"; Rec."CIO: Money Back")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Customer Input Option: Money Back';
                    ToolTip = 'Specifies the customer input options.';
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
                ToolTip = 'Upload HTML to be used for customer display.';

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
                ToolTip = 'Download HTML to be used for customer display.';

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
            action("Delete HTML")
            {
                ApplicationArea = NPRRetail;
                Image = Delete;
                ToolTip = 'Delete HTML';

                trigger OnAction()
                begin
                    if (Rec."HTML Blob".HasValue() and Rec.CalcFields("HTML Blob")) then
                        Clear(Rec."HTML Blob");
                end;
            }
            action(DeployPackageFromAzureBlob)
            {
                Caption = 'Download Template Data';
                Image = ImportDatabase;

                //RunObject = page "NPR HTML Disp Prof Azure";
                ToolTip = 'Downloads Template Data.';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    GetHtmlFile();
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
        }

    }
    local procedure GetHtmlFile()
    var
        rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        packageList: List of [Text];
        TempRetailList: Record "NPR Retail List" temporary;
        package: Text;
        outStream: OutStream;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        htmlContent: Text;
    begin
        rapidstartBaseDataMgt.GetAllPackagesInBlobStorage('https://npretailbasedata.blob.core.windows.net/pos-html-profile/?restype=container&comp=list', packageList);
        foreach package in packageList do begin
            TempRetailList.Number += 1;
            TempRetailList.Value := CopyStr(package, 1, MaxStrLen(TempRetailList.Value));
            TempRetailList.Choice := CopyStr(package, 1, MaxStrLen(TempRetailList.Choice));
            TempRetailList.Insert();
        end;

        if Page.Runmodal(Page::"NPR Retail List", TempRetailList) <> Action::LookupOK then
            exit;
        if (not Client.Get('https://npretailbasedata.blob.core.windows.net/pos-html-profile/' + TempRetailList.Value, ResponseMessage)) then
            Error('Failed download: %1', ResponseMessage.ReasonPhrase);
        if (not ResponseMessage.IsSuccessStatusCode) then
            Error('Web servie was not successfull: %1', ResponseMessage.ReasonPhrase);
        if not (ResponseMessage.Content.ReadAs(htmlContent)) then
            Error('Could not read the content of the file');
        Rec."HTML Blob".CreateOutStream(outStream);
        outStream.WriteText(htmlContent);
        Rec.Modify();
    end;
}