page 6184493 "Pepper Terminal Card"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.25/BR/20160509  CASE 231481 Added field Fixed Currency Code
    // NPR5.25/BR/20160608  CASE 231481 Added fields Customer ID, License ID, License File, License Action
    // NPR5.27/BR/20161025  CASE 255131 Added field Close Automatically
    // NPR5.29/BR/20161221  CASE 261673 Added Nets requirement for signature confirmation

    Caption = 'Pepper Terminal Card';
    PageType = Card;
    SourceTable = "Pepper Terminal";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Instance ID";"Instance ID")
                {
                }
                field("Configuration Code";"Configuration Code")
                {
                }
                field(Language;Language)
                {
                }
                field("Pepper Receipt Encoding";"Pepper Receipt Encoding")
                {
                }
                field("NAV Receipt Encoding";"NAV Receipt Encoding")
                {
                }
                field("Com Port";"Com Port")
                {
                }
                field("IP Address";"IP Address")
                {
                }
                field("Terminal Type Code";"Terminal Type Code")
                {
                }
                field("Receipt Format";"Receipt Format")
                {
                }
                field("Fixed Currency Code";"Fixed Currency Code")
                {
                }
                field("Open Automatically";"Open Automatically")
                {
                }
                field("Close Automatically";"Close Automatically")
                {
                }
                field("Cancel at Wrong Signature";"Cancel at Wrong Signature")
                {
                }
                field("Customer ID";"Customer ID")
                {
                }
                field("License ID";"License ID")
                {
                }
                field(License;HasLicense)
                {
                    Editable = false;
                }
                field("Additional Parameters";HasAdditionalParameters)
                {
                    Editable = false;
                }
            }
            group(Matchbox)
            {
                field("Matchbox Files";"Matchbox Files")
                {
                }
                field("Matchbox Company ID";"Matchbox Company ID")
                {
                }
                field("Matchbox Shop ID";"Matchbox Shop ID")
                {
                }
                field("Matchbox POS ID";"Matchbox POS ID")
                {
                }
                field("Matchbox File Name";"Matchbox File Name")
                {
                }
            }
            group("Print Files")
            {
                field("Print File Open";"Print File Open")
                {
                }
                field("Print File Close";"Print File Close")
                {
                }
                field("Print File Transaction";"Print File Transaction")
                {
                }
                field("Print File CC Transaction";"Print File CC Transaction")
                {
                }
                field("Print File Difference";"Print File Difference")
                {
                }
                field("Print File End of Day";"Print File End of Day")
                {
                }
                field("Print File Journal";"Print File Journal")
                {
                }
                field("Print File Initialisation";"Print File Initialisation")
                {
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

                    trigger OnAction()
                    begin
                        ShowFile(1);
                    end;
                }
            }
            group(Delete)
            {
                action(DeleteLicense)
                {
                    Caption = 'License';
                    Image = DeleteQtyToHandle;

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

                    trigger OnAction()
                    begin
                        ExportFile(0);
                    end;
                }
                action(ExportAddtionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = TransmitElectronicDoc;

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
                RunObject = Page "EFT Transaction Requests";
                RunPageLink = "Pepper Terminal Code"=FIELD(Code);
                RunPageView = SORTING("Entry No.")
                              ORDER(Ascending);
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
        CalcFields("Additional Parameters File","License File");
        HasLicense := "License File".HasValue;
        //+NPR5.25 [231481]
        HasAdditionalParameters := "Additional Parameters File".HasValue;
    end;
}

