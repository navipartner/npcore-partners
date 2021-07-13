page 6184493 "NPR Pepper Terminal Card"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.25/BR/20160509  CASE 231481 Added field Fixed Currency Code
    // NPR5.25/BR/20160608  CASE 231481 Added fields Customer ID, License ID, License File, License Action
    // NPR5.27/BR/20161025  CASE 255131 Added field Close Automatically
    // NPR5.29/BR/20161221  CASE 261673 Added Nets requirement for signature confirmation

    Caption = 'Pepper Terminal Card';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Pepper Terminal";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Instance ID"; Rec."Instance ID")
                {

                    ToolTip = 'Specifies the value of the Instance ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Configuration Code"; Rec."Configuration Code")
                {

                    ToolTip = 'Specifies the value of the Configuration Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Language; Rec.Language)
                {

                    ToolTip = 'Specifies the value of the Language field';
                    ApplicationArea = NPRRetail;
                }
                field("Pepper Receipt Encoding"; Rec."Pepper Receipt Encoding")
                {

                    ToolTip = 'Specifies the value of the Pepper Receipt Encoding field';
                    ApplicationArea = NPRRetail;
                }
                field("NAV Receipt Encoding"; Rec."NAV Receipt Encoding")
                {

                    ToolTip = 'Specifies the value of the NAV Receipt Encoding field';
                    ApplicationArea = NPRRetail;
                }
                field("Com Port"; Rec."Com Port")
                {

                    ToolTip = 'Specifies the value of the Com Port field';
                    ApplicationArea = NPRRetail;
                }
                field("IP Address"; Rec."IP Address")
                {

                    ToolTip = 'Specifies the value of the IP Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal Type Code"; Rec."Terminal Type Code")
                {

                    ToolTip = 'Specifies the value of the Terminal Type Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Format"; Rec."Receipt Format")
                {

                    ToolTip = 'Specifies the value of the Receipt Format field';
                    ApplicationArea = NPRRetail;
                }
                field("Fixed Currency Code"; Rec."Fixed Currency Code")
                {

                    ToolTip = 'Specifies the value of the Fixed Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Open Automatically"; Rec."Open Automatically")
                {

                    ToolTip = 'Specifies the value of the Open Automatically field';
                    ApplicationArea = NPRRetail;
                }
                field("Close Automatically"; Rec."Close Automatically")
                {

                    ToolTip = 'Specifies the value of the Close Automatically field';
                    ApplicationArea = NPRRetail;
                }
                field("Cancel at Wrong Signature"; Rec."Cancel at Wrong Signature")
                {

                    ToolTip = 'Specifies the value of the Cancel at Wrong Signature field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer ID"; Rec."Customer ID")
                {

                    ToolTip = 'Specifies the value of the Customer ID field';
                    ApplicationArea = NPRRetail;
                }
                field("License ID"; Rec."License ID")
                {

                    ToolTip = 'Specifies the value of the License ID field';
                    ApplicationArea = NPRRetail;
                }
                field(License; HasLicense)
                {

                    Caption = 'License';
                    Editable = false;
                    ToolTip = 'Specifies the value of the HasLicense field';
                    ApplicationArea = NPRRetail;
                }
                field("Additional Parameters"; HasAdditionalParameters)
                {

                    Caption = 'Additional Parameters';
                    Editable = false;
                    ToolTip = 'Specifies the value of the HasAdditionalParameters field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Matchbox)
            {
                field("Matchbox Files"; Rec."Matchbox Files")
                {

                    ToolTip = 'Specifies the value of the Matchbox Files field';
                    ApplicationArea = NPRRetail;
                }
                field("Matchbox Company ID"; Rec."Matchbox Company ID")
                {

                    ToolTip = 'Specifies the value of the Matchbox Company ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Matchbox Shop ID"; Rec."Matchbox Shop ID")
                {

                    ToolTip = 'Specifies the value of the Matchbox Shop ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Matchbox POS ID"; Rec."Matchbox POS ID")
                {

                    ToolTip = 'Specifies the value of the Matchbox POS ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Matchbox File Name"; Rec."Matchbox File Name")
                {

                    ToolTip = 'Specifies the value of the Matchbox File Name field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Print Files")
            {
                field("Print File Open"; Rec."Print File Open")
                {

                    ToolTip = 'Specifies the value of the Print File Open field';
                    ApplicationArea = NPRRetail;
                }
                field("Print File Close"; Rec."Print File Close")
                {

                    ToolTip = 'Specifies the value of the Print File Close field';
                    ApplicationArea = NPRRetail;
                }
                field("Print File Transaction"; Rec."Print File Transaction")
                {

                    ToolTip = 'Specifies the value of the Print File Transaction field';
                    ApplicationArea = NPRRetail;
                }
                field("Print File CC Transaction"; Rec."Print File CC Transaction")
                {

                    ToolTip = 'Specifies the value of the Print File CC Transaction field';
                    ApplicationArea = NPRRetail;
                }
                field("Print File Difference"; Rec."Print File Difference")
                {

                    ToolTip = 'Specifies the value of the Print File Difference field';
                    ApplicationArea = NPRRetail;
                }
                field("Print File End of Day"; Rec."Print File End of Day")
                {

                    ToolTip = 'Specifies the value of the Print File End of Day field';
                    ApplicationArea = NPRRetail;
                }
                field("Print File Journal"; Rec."Print File Journal")
                {

                    ToolTip = 'Specifies the value of the Print File Journal field';
                    ApplicationArea = NPRRetail;
                }
                field("Print File Initialisation"; Rec."Print File Initialisation")
                {

                    ToolTip = 'Specifies the value of the Print File Initialisation field';
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

                    ToolTip = 'Executes the License action';
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

                    ToolTip = 'Executes the Additional Parameters action';
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

                    ToolTip = 'Executes the License action';
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

                    ToolTip = 'Executes the Additional Parameters action';
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

                    ToolTip = 'Executes the License action';
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

                    ToolTip = 'Executes the Additional parameters action';
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

                    ToolTip = 'Executes the License action';
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

                    ToolTip = 'Executes the Additional Parameters action';
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

                ToolTip = 'Executes the Transaction Requests action';
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

