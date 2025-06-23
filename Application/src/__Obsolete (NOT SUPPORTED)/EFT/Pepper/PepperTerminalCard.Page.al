page 6184493 "NPR Pepper Terminal Card"
{
    Extensible = False;
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.25/BR/20160509  CASE 231481 Added field Fixed Currency Code
    // NPR5.25/BR/20160608  CASE 231481 Added fields Customer ID, License ID, License File, License Action
    // NPR5.27/BR/20161025  CASE 255131 Added field Close Automatically
    // NPR5.29/BR/20161221  CASE 261673 Added Nets requirement for signature confirmation

    Caption = 'Pepper Terminal Card';
    PageType = Card;
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    SourceTable = "NPR Pepper Terminal";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the unique identifier for the terminal.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies a brief description of the terminal.';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the register number associated with the POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field("Instance ID"; Rec."Instance ID")
                {

                    ToolTip = 'Specifies the unique identifier for the terminal instance.';
                    ApplicationArea = NPRRetail;
                }
                field("Configuration Code"; Rec."Configuration Code")
                {

                    ToolTip = 'Specifies the code for the terminal configuration.';
                    ApplicationArea = NPRRetail;
                }
                field(Language; Rec.Language)
                {

                    ToolTip = 'Specifies the language used for the terminal.';
                    ApplicationArea = NPRRetail;
                }
                field("Pepper Receipt Encoding"; Rec."Pepper Receipt Encoding")
                {

                    ToolTip = 'Specifies the encoding format for Pepper receipts.';
                    ApplicationArea = NPRRetail;
                }
                field("NAV Receipt Encoding"; Rec."NAV Receipt Encoding")
                {

                    ToolTip = 'Specifies the encoding format for Business Central receipts.';
                    ApplicationArea = NPRRetail;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-06-28';
                    ObsoleteReason = 'Will be removed when Pepper TSD is removed.';
                }
                field("Com Port"; Rec."Com Port")
                {

                    ToolTip = 'Specifies the communication port used by the terminal.';
                    ApplicationArea = NPRRetail;
                }
                field("IP Address"; Rec."IP Address")
                {

                    ToolTip = 'Specifies the IP address associated with the terminal.';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal Type Code"; Rec."Terminal Type Code")
                {

                    ToolTip = 'Specifies the code representing the terminal type.';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Format"; Rec."Receipt Format")
                {

                    ToolTip = 'Specifies the format used for receipts.';
                    ApplicationArea = NPRRetail;
                }
                field("Fixed Currency Code"; Rec."Fixed Currency Code")
                {

                    ToolTip = 'Specifies the currency code for fixed transactions.';
                    ApplicationArea = NPRRetail;
                }
                field("Open Automatically"; Rec."Open Automatically")
                {

                    ToolTip = ' Indicates whether the terminal opens automatically.';
                    ApplicationArea = NPRRetail;
                }
                field("Close Automatically"; Rec."Close Automatically")
                {

                    ToolTip = 'Indicates whether the terminal closes automatically.';
                    ApplicationArea = NPRRetail;
                }
                field("Cancel at Wrong Signature"; Rec."Cancel at Wrong Signature")
                {

                    ToolTip = 'Indicates whether the terminal cancels on a wrong signature.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer ID"; Rec."Customer ID")
                {

                    ToolTip = 'Specifies the unique identifier for the customer.';
                    ApplicationArea = NPRRetail;
                }
                field("License ID"; Rec."License ID")
                {

                    ToolTip = 'Specifies the unique identifier for the license.';
                    ApplicationArea = NPRRetail;
                }
                field(License; HasLicense)
                {

                    Caption = 'License';
                    Editable = false;
                    ToolTip = 'Indicates whether the terminal has a license.';
                    ApplicationArea = NPRRetail;
                }
                field("Additional Parameters"; HasAdditionalParameters)
                {

                    Caption = 'Additional Parameters';
                    Editable = false;
                    ToolTip = 'Indicates whether the terminal has additional parameters.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Matchbox)
            {
                field("Matchbox Files"; Rec."Matchbox Files")
                {

                    ToolTip = 'Specifies information about the Matchbox configuration files.';
                    ApplicationArea = NPRRetail;
                }
                field("Matchbox Company ID"; Rec."Matchbox Company ID")
                {

                    ToolTip = 'Specifies the unique identifier for the Matchbox company associated with the terminal.';
                    ApplicationArea = NPRRetail;
                }
                field("Matchbox Shop ID"; Rec."Matchbox Shop ID")
                {

                    ToolTip = 'Specifies the unique identifier for the Matchbox shop associated with the terminal.';
                    ApplicationArea = NPRRetail;
                }
                field("Matchbox POS ID"; Rec."Matchbox POS ID")
                {

                    ToolTip = 'Specifies the unique identifier for the Matchbox POS unit associated with the terminal.';
                    ApplicationArea = NPRRetail;
                }
                field("Matchbox File Name"; Rec."Matchbox File Name")
                {

                    ToolTip = 'Specifies the name of the Matchbox configuration file associated with the terminal.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Print Files")
            {
                field("Print File Open"; Rec."Print File Open")
                {

                    ToolTip = 'Specifies the name of the print file for the sign-on ticket. In addition, an absolute or relative path preceding the file name can be specified. If the file name extension is “.xml” (not case-sensitive), the file will be created in the XML format.';
                    ApplicationArea = NPRRetail;
                }
                field("Print File Close"; Rec."Print File Close")
                {

                    ToolTip = 'Specifies the name of the print file for the sign-off ticket. In addition, an absolute or relative path preceding the file name can be specified. If the file name extension is “.xml” (not case-sensitive), the file will be created in the XML format.';
                    ApplicationArea = NPRRetail;
                }
                field("Print File Transaction"; Rec."Print File Transaction")
                {

                    ToolTip = 'Specifies the name of the print file for the transaction ticket (client receipt). In addition, an absolute or relative path preceding the file name can be specified. If the file name extension is “.xml” (not case-sensitive), the file will be created in the XML format.';
                    ApplicationArea = NPRRetail;
                }
                field("Print File CC Transaction"; Rec."Print File CC Transaction")
                {

                    ToolTip = 'Specifies the name of the print file for the additional credit card ticket (merchant receipt). In addition, an absolute or relative path preceding the file name can be specified. If the file name extension is “.xml” (not case-sensitive), the file will be created in the XML format.';
                    ApplicationArea = NPRRetail;
                }
                field("Print File Difference"; Rec."Print File Difference")
                {

                    ToolTip = 'Specifies the name of the print file for the difference ticket. In addition, an absolute or relative path preceding the file name can be specified. If the file name extension is “.xml” (not case-sensitive), the file will be created in the XML format.';
                    ApplicationArea = NPRRetail;
                }
                field("Print File End of Day"; Rec."Print File End of Day")
                {

                    ToolTip = 'Specifies the name of the print file for the end-of-day ticket. In addition, an absolute or relative path preceding the file name can be specified. If the file name extension is “.xml” (not case-sensitive), the file will be created in the XML format.';
                    ApplicationArea = NPRRetail;
                }
                field("Print File Journal"; Rec."Print File Journal")
                {

                    ToolTip = 'Specifies the name of the print file for the journal of the EFT terminal. In addition, an absolute or relative path preceding the file name can be specified. If the file name extension is “.xml” (not case-sensitive), the file will be created in the XML format.';
                    ApplicationArea = NPRRetail;
                }
                field("Print File Initialisation"; Rec."Print File Initialisation")
                {

                    ToolTip = 'Specifies the name of the print file for the journal of the EFT terminal. In addition, an absolute or relative path preceding the file name can be specified. If the file name extension is “.xml” (not case-sensitive), the file will be created in the XML format.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Import)
            {
                action(ImportLicense)
                {
                    Caption = 'License';
                    Image = ImportCodes;

                    ToolTip = 'Import a license file.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.UploadFile(0);
                        UpdateBLOBCheck();
                    end;
                }
                action(ImportAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = Import;

                    ToolTip = 'Import a license file.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.UploadFile(1);
                        UpdateBLOBCheck();
                    end;
                }
            }
            group(Show)
            {
                action(ShowLicense)
                {
                    Caption = 'License';
                    Image = ElectronicNumber;

                    ToolTip = 'Display the license file.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        UpdateBLOBCheck();
                        Rec.ShowFile(0);
                    end;
                }
                action(ShowAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = ElectronicDoc;

                    ToolTip = 'Display the license file.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowFile(1);
                    end;
                }
            }
            group("Delete")
            {
                action(DeleteLicense)
                {
                    Caption = 'License';
                    Image = DeleteQtyToHandle;

                    ToolTip = 'Delete the license file.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ClearFile(0);
                        UpdateBLOBCheck();
                    end;
                }
                action("DeleteAdditional Parameters")
                {
                    Caption = 'Additional parameters';
                    Image = DeleteXML;

                    ToolTip = 'Delete the additional parameter files.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ClearFile(1);
                        UpdateBLOBCheck();
                    end;
                }
            }
            group(Export)
            {
                action(ExportLicense)
                {
                    Caption = 'License';
                    Image = Export;

                    ToolTip = 'Delete the additional parameter files.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ExportFile(0);
                    end;
                }
                action(ExportAddtionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = TransmitElectronicDoc;

                    ToolTip = 'Export the additional parameter files.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ExportFile(1);
                    end;
                }
            }
        }
        area(navigation)
        {
            action("Transaction Requests")
            {
                Caption = 'Transaction Requests';
                Image = Transactions;
                RunObject = Page "NPR EFT Transaction Requests";
                RunPageLink = "Pepper Terminal Code" = FIELD(Code);
                RunPageView = SORTING("Entry No.")
                              ORDER(Ascending);

                ToolTip = 'View the transaction requests associated with the terminal.';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateBLOBCheck();
    end;

    var
        HasAdditionalParameters: Boolean;
        HasLicense: Boolean;

    local procedure UpdateBLOBCheck()
    begin

        Rec.CalcFields("Additional Parameters File", "License File");
        HasLicense := Rec."License File".HasValue;
        HasAdditionalParameters := Rec."Additional Parameters File".HasValue();
    end;
}

