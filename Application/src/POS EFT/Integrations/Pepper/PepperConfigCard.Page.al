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

    SourceTable = "NPR Pepper Config.";
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
                field(Version; Rec.Version)
                {

                    ToolTip = 'Specifies the value of the Version field';
                    ApplicationArea = NPRRetail;
                }
                field("Recovery Retry Attempts"; Rec."Recovery Retry Attempts")
                {

                    ToolTip = 'Specifies the value of the Recovery Retry Attempts field';
                    ApplicationArea = NPRRetail;
                }
                field(Mode; Rec.Mode)
                {

                    ToolTip = 'Specifies the value of the Mode field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Header and Footer Handling"; Rec."Header and Footer Handling")
                {

                    ToolTip = 'Specifies the value of the Header and Footer Handling field';
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
                field("Default POS Timeout (Seconds)"; Rec."Default POS Timeout (Seconds)")
                {

                    ToolTip = 'Specifies the value of the Default POS Timeout (Seconds) field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Detailed Error Messages"; Rec."Show Detailed Error Messages")
                {

                    ToolTip = 'Specifies the value of the Show Detailed Error Messages field';
                    ApplicationArea = NPRRetail;
                }
                field("Offline mode"; Rec."Offline mode")
                {

                    ToolTip = 'Specifies the value of the Offline mode field';
                    ApplicationArea = NPRRetail;
                }
                field("Min. Length Authorisation No."; Rec."Min. Length Authorisation No.")
                {

                    ToolTip = 'Specifies the value of the Min. Length Authorisation No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Max. Length Authorisation No."; Rec."Max. Length Authorisation No.")
                {

                    ToolTip = 'Specifies the value of the Max. Length Authorisation No. field';
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
            }
            group(Logging)
            {
                field("Logging Target"; Rec."Logging Target")
                {

                    ToolTip = 'Specifies the value of the Logging Target field';
                    ApplicationArea = NPRRetail;
                }
                field("Logging Level"; Rec."Logging Level")
                {

                    ToolTip = 'Specifies the value of the Logging Level field';
                    ApplicationArea = NPRRetail;
                }
                field("Logging Max. File Size (MB)"; Rec."Logging Max. File Size (MB)")
                {

                    ToolTip = 'Specifies the value of the Logging Max. File Size (MB) field';
                    ApplicationArea = NPRRetail;
                }
                field("Logging Directory"; Rec."Logging Directory")
                {

                    ToolTip = 'Specifies the value of the Logging Directory field';
                    ApplicationArea = NPRRetail;
                }
                field("Logging Archive Directory"; Rec."Logging Archive Directory")
                {

                    ToolTip = 'Specifies the value of the Logging Archive Directory field';
                    ApplicationArea = NPRRetail;
                }
                field("Logging Archive Max. Age Days"; Rec."Logging Archive Max. Age Days")
                {

                    ToolTip = 'Specifies the value of the Logging Archive Max. Age Days field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Files)
            {
                field("Card Type File Full Path"; Rec."Card Type File Full Path")
                {

                    ToolTip = 'Specifies the value of the Card Type File Full Path field';
                    ApplicationArea = NPRRetail;
                }
                field("License File Full Path"; Rec."License File Full Path")
                {

                    ToolTip = 'Specifies the value of the License File Full Path field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Directories)
            {
                field("Ticket Directory"; Rec."Ticket Directory")
                {

                    ToolTip = 'Specifies the value of the Ticket Directory field';
                    ApplicationArea = NPRRetail;
                }
                field("Journal Directory"; Rec."Journal Directory")
                {

                    ToolTip = 'Specifies the value of the Journal Directory field';
                    ApplicationArea = NPRRetail;
                }
                field("Matchbox Directory"; Rec."Matchbox Directory")
                {

                    ToolTip = 'Specifies the value of the Matchbox Directory field';
                    ApplicationArea = NPRRetail;
                }
                field("Messages Directory"; Rec."Messages Directory")
                {

                    ToolTip = 'Specifies the value of the Messages Directory field';
                    ApplicationArea = NPRRetail;
                }
                field("Persistance Directory"; Rec."Persistance Directory")
                {

                    ToolTip = 'Specifies the value of the Persistance Directory field';
                    ApplicationArea = NPRRetail;
                }
                field("Working Directory"; Rec."Working Directory")
                {

                    ToolTip = 'Specifies the value of the Working Directory field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Transaction Types")
            {
                field(Open; Rec."Transaction Type Open Code")
                {

                    ToolTip = 'Specifies the value of the Transaction Type Open Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Payment; Rec."Transaction Type Payment Code")
                {

                    ToolTip = 'Specifies the value of the Transaction Type Payment Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Close; Rec."Transaction Type Close Code")
                {

                    ToolTip = 'Specifies the value of the Transaction Type Close Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Refund; Rec."Transaction Type Refund Code")
                {

                    ToolTip = 'Specifies the value of the Transaction Type Refund Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Recover; Rec."Transaction Type Recover Code")
                {

                    ToolTip = 'Specifies the value of the Transaction Type Recover Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Transaction Type Auxilary Code"; Rec."Transaction Type Auxilary Code")
                {

                    ToolTip = 'Specifies the value of the Transaction Type Auxilary Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Transaction Type Install Code"; Rec."Transaction Type Install Code")
                {

                    ToolTip = 'Specifies the value of the Transaction Type Install Code field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Closing)
            {
                field("End of Day on Close"; Rec."End of Day on Close")
                {

                    ToolTip = 'Specifies the value of the End of Day on Close field';
                    ApplicationArea = NPRRetail;
                }
                field("Unload Library on Close"; Rec."Unload Library on Close")
                {

                    ToolTip = 'Specifies the value of the Unload Library on Close field';
                    ApplicationArea = NPRRetail;
                }
                field("End of Day Receipt Mandatory"; Rec."End of Day Receipt Mandatory")
                {

                    ToolTip = 'Specifies the value of the End of Day Receipt Mandatory field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Instances action';
                ApplicationArea = NPRRetail;
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
                Caption = 'Show';
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
                action(ShowConfigXML)
                {
                    Caption = 'Configuration XML';
                    Image = CreateXMLFile;

                    ToolTip = 'Executes the Configuration XML action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        UpdateBLOBCheck();
                        Rec.ShowFile(1);
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
                Caption = 'Export';
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
                action(ExportConfig)
                {
                    Caption = 'Configuration XML';
                    Image = ExportElectronicDocument;

                    ToolTip = 'Executes the Configuration XML action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ExportFile(1);
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
                        Rec.ExportFile(2);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateBLOBCheck();
    end;

    var
        HasLicense: Boolean;
        HasAdditionalParameters: Boolean;

    local procedure UpdateBLOBCheck()
    begin
        Rec.CalcFields("License File", "Additional Parameters");
        HasLicense := Rec."License File".HasValue();
        HasAdditionalParameters := Rec."Additional Parameters".HasValue();
    end;
}

