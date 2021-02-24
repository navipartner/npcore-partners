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
    ApplicationArea = All;
    SourceTable = "NPR Pepper Terminal";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Instance ID"; "Instance ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Instance ID field';
                }
                field("Configuration Code"; "Configuration Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Configuration Code field';
                }
                field(Language; Language)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Language field';
                }
                field("Pepper Receipt Encoding"; "Pepper Receipt Encoding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pepper Receipt Encoding field';
                }
                field("NAV Receipt Encoding"; "NAV Receipt Encoding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NAV Receipt Encoding field';
                }
                field("Com Port"; "Com Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Com Port field';
                }
                field("IP Address"; "IP Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the IP Address field';
                }
                field("Terminal Type Code"; "Terminal Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Type Code field';
                }
                field("Receipt Format"; "Receipt Format")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Format field';
                }
                field("Fixed Currency Code"; "Fixed Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Currency Code field';
                }
                field("Open Automatically"; "Open Automatically")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open Automatically field';
                }
                field("Close Automatically"; "Close Automatically")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Close Automatically field';
                }
                field("Cancel at Wrong Signature"; "Cancel at Wrong Signature")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cancel at Wrong Signature field';
                }
                field("Customer ID"; "Customer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer ID field';
                }
                field("License ID"; "License ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the License ID field';
                }
                field(License; HasLicense)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the HasLicense field';
                }
                field("Additional Parameters"; HasAdditionalParameters)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the HasAdditionalParameters field';
                }
            }
            group(Matchbox)
            {
                field("Matchbox Files"; "Matchbox Files")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Matchbox Files field';
                }
                field("Matchbox Company ID"; "Matchbox Company ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Matchbox Company ID field';
                }
                field("Matchbox Shop ID"; "Matchbox Shop ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Matchbox Shop ID field';
                }
                field("Matchbox POS ID"; "Matchbox POS ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Matchbox POS ID field';
                }
                field("Matchbox File Name"; "Matchbox File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Matchbox File Name field';
                }
            }
            group("Print Files")
            {
                field("Print File Open"; "Print File Open")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print File Open field';
                }
                field("Print File Close"; "Print File Close")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print File Close field';
                }
                field("Print File Transaction"; "Print File Transaction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print File Transaction field';
                }
                field("Print File CC Transaction"; "Print File CC Transaction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print File CC Transaction field';
                }
                field("Print File Difference"; "Print File Difference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print File Difference field';
                }
                field("Print File End of Day"; "Print File End of Day")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print File End of Day field';
                }
                field("Print File Journal"; "Print File Journal")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print File Journal field';
                }
                field("Print File Initialisation"; "Print File Initialisation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print File Initialisation field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        UploadFile(0);
                        UpdateBLOBCheck;
                    end;
                }
                action(ImportAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = Import;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Additional Parameters action';

                    trigger OnAction()
                    begin
                        UploadFile(1);
                        UpdateBLOBCheck;
                    end;
                }
            }
            group(Show)
            {
                action(ShowLicense)
                {
                    Caption = 'License';
                    Image = ElectronicNumber;
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        UpdateBLOBCheck;
                        ShowFile(0);
                    end;
                }
                action(ShowAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = ElectronicDoc;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Additional Parameters action';

                    trigger OnAction()
                    begin
                        ShowFile(1);
                    end;
                }
            }
            group("Delete")
            {
                action(DeleteLicense)
                {
                    Caption = 'License';
                    Image = DeleteQtyToHandle;
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        ClearFile(0);
                        UpdateBLOBCheck;
                    end;
                }
                action("DeleteAdditional Parameters")
                {
                    Caption = 'Additional parameters';
                    Image = DeleteXML;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Additional parameters action';

                    trigger OnAction()
                    begin
                        ClearFile(1);
                        UpdateBLOBCheck;
                    end;
                }
            }
            group(Export)
            {
                action(ExportLicense)
                {
                    Caption = 'License';
                    Image = Export;
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        ExportFile(0);
                    end;
                }
                action(ExportAddtionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = TransmitElectronicDoc;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Additional Parameters action';

                    trigger OnAction()
                    begin
                        ExportFile(1);
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
                ApplicationArea = All;
                ToolTip = 'Executes the Transaction Requests action';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateBLOBCheck;
    end;

    var
        HasAdditionalParameters: Boolean;
        HasLicense: Boolean;

    local procedure UpdateBLOBCheck()
    begin
        //-NPR5.25 [231481]
        //CALCFIELDS("Additional Parameters File");
        CalcFields("Additional Parameters File", "License File");
        HasLicense := "License File".HasValue;
        //+NPR5.25 [231481]
        HasAdditionalParameters := "Additional Parameters File".HasValue;
    end;
}

