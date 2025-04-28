page 6184912 "NPR HU L POS Audit Log Aux."
{
    ApplicationArea = NPRHULaurelFiscal;
    Caption = 'HU Laurel POS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR HU L POS Audit Log Aux.";
    SourceTableView = sorting("Audit Entry No.") order(descending);
    PromotedActionCategories = 'New,Process,Report,Process Receipt,Receipt Print,Download,Related';
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Audit Entry Type"; Rec."Audit Entry Type")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the Audit Entry Type.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the Audit Entry No.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the POS Entry No. related to this record.';

                    trigger OnDrillDown()
                    var
                        POSEntry: Record "NPR POS Entry";
                        POSEntryList: Page "NPR POS Entry List";
                    begin
                        if not (Rec."Audit Entry Type" in [Rec."Audit Entry Type"::"POS Entry"]) then
                            exit;

                        POSEntry.FilterGroup(2);
                        POSEntry.SetRange("Entry No.", Rec."POS Entry No.");
                        POSEntry.FilterGroup(0);
                        POSEntryList.SetTableView(POSEntry);
                        POSEntryList.Run();
                    end;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the Transaction Type.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the Entry Date.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the POS store code from which the related record was created.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the POS unit number from which the related record was created.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the salesperson which created this record.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the Source Document No.';
                }
                field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the total amount including taxes for the transaction.';
                }
                field("Change Amount"; Rec."Change Amount")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the Change Amount field.';
                }
                field("Rounding Amount"; Rec."Rounding Amount")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the Rounding Amount field.';
                }
                field("FCU Full Document No."; Rec."FCU Full Document No.")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the FCU Full Document No. field.';
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
                PromotedCategory = Category6;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Downloads the request content related to the selected entry.';

                trigger OnAction()
                var
                    FileMgt: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    OStream: OutStream;
                    FileNameJsonLbl: Label 'Request_%1.json', Comment = '%1 - FCU Full Document No.', Locked = true;
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
                PromotedCategory = Category6;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Downloads the response content related to the selected entry.';

                trigger OnAction()
                var
                    FileMgt: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    OStream: OutStream;
                    FileNameJsonLbl: Label 'Response_%1.json', Comment = '%1 - FCU Full Document No.', Locked = true;
                begin
                    TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                    if Rec."Response Content".HasValue() then begin
                        Rec."Response Content".ExportStream(OStream);
                        FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameJsonLbl, Rec."FCU Full Document No."), true);
                    end;
                end;
            }
            action(OpenRelatedDocument)
            {
                ApplicationArea = NPRHULaurelFiscal;
                Caption = 'Open Related Document';
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Category7;
                PromotedOnly = true;
                ToolTip = 'Opens the document related to the selected transaction record.';
                trigger OnAction()
                var
                    POSEntry: Record "NPR POS Entry";
                begin
                    POSEntry.Get(Rec."POS Entry No.");
                    Page.RunModal(Page::"NPR POS Entry Card", POSEntry);
                end;
            }
        }
    }
}
