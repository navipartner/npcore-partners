page 6184954 "NPR HU L Cash Transactions"
{
    ApplicationArea = NPRHULaurelFiscal;
    UsageCategory = Administration;
    Caption = 'HU Laurel Cash Transactions';
    Extensible = false;
    PageType = List;
    Editable = false;
    SourceTable = "NPR HU L Cash Transaction";
    SourceTableView = sorting("Entry No.") order(descending);
    PromotedActionCategories = 'New,Process,Report,Download';

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the Entry Type field.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the POS Store Code field.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the POS Unit No. field.';
                }
                field("Cash Amount"; Rec."Cash Amount")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the Cash Amount field.';
                }
                field("Rounding Amount"; Rec."Rounding Amount")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the Rounding Amount field.';
                }
                field("FCU ID"; Rec."FCU ID")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the FCU ID field.';
                }
                field("FCU Document No."; Rec."FCU Document No.")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the FCU Document No. field.';
                }
                field("FCU Full Document No."; Rec."FCU Full Document No.")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the FCU Full Document No. field.';
                }
                field("FCU Closure No."; Rec."FCU Closure No.")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the FCU Closure No. field.';
                }
                field("FCU Timestamp"; Rec."FCU Timestamp")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the FCU Timestamp field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(DownloadRequestContent)
            {
                ApplicationArea = NPRHULaurelFiscal;
                Caption = 'Download Request Content';
                Image = Find;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Downloads the request content related to the selected entry.';

                trigger OnAction()
                var
                    FileMgt: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    OStream: OutStream;
                    FileNameJsonLbl: Label 'Request_%1.json', Locked = true;
                begin
                    TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                    if Rec."Request Content".HasValue() then begin
                        Rec."Request Content".ExportStream(OStream);
                        FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameJsonLbl, Rec."FCU Full Document No."), true);
                    end;
                end;
            }
            action(DownloadResponseContent)
            {
                ApplicationArea = NPRHULaurelFiscal;
                Caption = 'Download Response Content';
                Image = Find;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Downloads the response content related to the selected entry.';

                trigger OnAction()
                var
                    FileMgt: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    OStream: OutStream;
                    FileNameJsonLbl: Label 'Response_%1.json', Locked = true;
                begin
                    TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                    if Rec."Response Content".HasValue() then begin
                        Rec."Response Content".ExportStream(OStream);
                        FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameJsonLbl, Rec."FCU Full Document No."), true);
                    end;
                end;
            }
        }
    }
}