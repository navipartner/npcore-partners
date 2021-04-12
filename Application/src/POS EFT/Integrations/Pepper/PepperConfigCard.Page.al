page 6184490 "NPR Pepper Config. Card"
{
    // NPR5.22\BR\20160316  CASE 231481 Object Created
    // NPR5.22\BR\20160412  CASE 231481 Added Export Buttons
    // NPR5.22\BR\20160412  CASE 231481 Added fields "End of Day on Close", "Unload Library on Close", "End of Day Receipt Mandatory"
    // NPR5.22\BR\20160413  CASE 231481 Added fields Offline Mode
    // NPR5.25\BR\20160504  CASE 231481 Added Transaction Type Install
    // NPR5.25/BR/20160608  CASE 231481 Added fields Customer ID, License ID
    // NPR5.34/BR/20170320  CASE 268697 Added fields Min. Length Authorisation No. and Max. Length Authorisation No.

    Caption = 'Pepper Configuration Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Pepper Config.";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version field';
                }
                field("Recovery Retry Attempts"; Rec."Recovery Retry Attempts")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recovery Retry Attempts field';
                }
                field(Mode; Rec.Mode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mode field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Header and Footer Handling"; Rec."Header and Footer Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Header and Footer Handling field';
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
                field("Default POS Timeout (Seconds)"; Rec."Default POS Timeout (Seconds)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Timeout (Seconds) field';
                }
                field("Show Detailed Error Messages"; Rec."Show Detailed Error Messages")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Detailed Error Messages field';
                }
                field("Offline mode"; Rec."Offline mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Offline mode field';
                }
                field("Min. Length Authorisation No."; Rec."Min. Length Authorisation No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Min. Length Authorisation No. field';
                }
                field("Max. Length Authorisation No."; Rec."Max. Length Authorisation No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. Length Authorisation No. field';
                }
                field("Customer ID"; Rec."Customer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer ID field';
                }
                field("License ID"; Rec."License ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the License ID field';
                }
            }
            group(Logging)
            {
                field("Logging Target"; Rec."Logging Target")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Logging Target field';
                }
                field("Logging Level"; Rec."Logging Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Logging Level field';
                }
                field("Logging Max. File Size (MB)"; Rec."Logging Max. File Size (MB)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Logging Max. File Size (MB) field';
                }
                field("Logging Directory"; Rec."Logging Directory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Logging Directory field';
                }
                field("Logging Archive Directory"; Rec."Logging Archive Directory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Logging Archive Directory field';
                }
                field("Logging Archive Max. Age Days"; Rec."Logging Archive Max. Age Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Logging Archive Max. Age Days field';
                }
            }
            group(Files)
            {
                field("Card Type File Full Path"; Rec."Card Type File Full Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Type File Full Path field';
                }
                field("License File Full Path"; Rec."License File Full Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the License File Full Path field';
                }
            }
            group(Directories)
            {
                field("Ticket Directory"; Rec."Ticket Directory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Directory field';
                }
                field("Journal Directory"; Rec."Journal Directory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Directory field';
                }
                field("Matchbox Directory"; Rec."Matchbox Directory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Matchbox Directory field';
                }
                field("Messages Directory"; Rec."Messages Directory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Messages Directory field';
                }
                field("Persistance Directory"; Rec."Persistance Directory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Persistance Directory field';
                }
                field("Working Directory"; Rec."Working Directory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Working Directory field';
                }
            }
            group("Transaction Types")
            {
                field(Open; Rec."Transaction Type Open Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Type Open Code field';
                }
                field(Payment; Rec."Transaction Type Payment Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Type Payment Code field';
                }
                field(Close; Rec."Transaction Type Close Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Type Close Code field';
                }
                field(Refund; Rec."Transaction Type Refund Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Type Refund Code field';
                }
                field(Recover; Rec."Transaction Type Recover Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Type Recover Code field';
                }
                field("Transaction Type Auxilary Code"; Rec."Transaction Type Auxilary Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Type Auxilary Code field';
                }
                field("Transaction Type Install Code"; Rec."Transaction Type Install Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Type Install Code field';
                }
            }
            group(Closing)
            {
                field("End of Day on Close"; Rec."End of Day on Close")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End of Day on Close field';
                }
                field("Unload Library on Close"; Rec."Unload Library on Close")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unload Library on Close field';
                }
                field("End of Day Receipt Mandatory"; Rec."End of Day Receipt Mandatory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End of Day Receipt Mandatory field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Instances)
            {
                Caption = 'Instances';
                Image = Server;
                RunObject = Page "NPR Pepper Instances";
                RunPageLink = "Configuration Code" = FIELD(Code);
                RunPageView = SORTING(ID)
                              ORDER(Ascending);
                ApplicationArea = All;
                ToolTip = 'Executes the Instances action';
            }
        }
        area(processing)
        {
            group(Import)
            {
                Caption = 'Import';
                action(ImportLicense)
                {
                    Caption = 'License';
                    Image = ImportCodes;
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        Rec.UploadFile(0);
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
                        Rec.UploadFile(1);
                        UpdateBLOBCheck;
                    end;
                }
            }
            group(Show)
            {
                Caption = 'Show';
                action(ShowLicense)
                {
                    Caption = 'License';
                    Image = ElectronicNumber;
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        UpdateBLOBCheck;
                        Rec.ShowFile(0);
                    end;
                }
                action(ShowConfigXML)
                {
                    Caption = 'Configuration XML';
                    Image = CreateXMLFile;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Configuration XML action';

                    trigger OnAction()
                    begin
                        UpdateBLOBCheck;
                        Rec.ShowFile(1);
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
                        Rec.ShowFile(2);
                    end;
                }
            }
            group("Delete")
            {
                Caption = 'Delete';
                action(DeleteLicense)
                {
                    Caption = 'License';
                    Image = DeleteQtyToHandle;
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        Rec.ClearFile(0);
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
                        Rec.ClearFile(1);
                        UpdateBLOBCheck;
                    end;
                }
            }
            group(Export)
            {
                Caption = 'Export';
                action(ExportLicense)
                {
                    Caption = 'License';
                    Image = Export;
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        Rec.ExportFile(0);
                    end;
                }
                action(ExportConfig)
                {
                    Caption = 'Configuration XML';
                    Image = ExportElectronicDocument;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Configuration XML action';

                    trigger OnAction()
                    begin
                        Rec.ExportFile(1);
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
                        Rec.ExportFile(2);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateBLOBCheck;
    end;

    var
        HasLicense: Boolean;
        HasAdditionalParameters: Boolean;

    local procedure UpdateBLOBCheck()
    begin
        Rec.CalcFields("License File", "Additional Parameters");
        HasLicense := "License File".HasValue;
        HasAdditionalParameters := "Additional Parameters".HasValue;
    end;
}

