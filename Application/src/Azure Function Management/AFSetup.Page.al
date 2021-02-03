page 6151570 "NPR AF Setup"
{

    Caption = 'AF Setup';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR AF Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Enable Azure Functions"; "Enable Azure Functions")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable Azure Functions field';
                }
                field("Customer Tag"; "Customer Tag")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Tag field';
                }
                field("Web Service Is Published"; "Web Service Is Published")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Is Published field';
                }
                field("Web Service Url"; "Web Service Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Url field';
                }
            }
            group("Spire Barcode")
            {
                Caption = 'Spire Barcode';
                field("Spire Barcode - API Key"; "Spire Barcode - API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Spire Barcode - API Key field';
                }
                field("Spire Barcode - Base Url"; "Spire Barcode - Base Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Spire Barcode - Base Url field';
                }
                field("Spire Barcode - API Routing"; "Spire Barcode - API Routing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Spire Barcode - API Routing field';
                }
            }
            group(Control6014405)
            {
                Caption = 'Notification Hub';
                field("Notification - Base Url"; "Notification - Base Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification - Base Url field';
                }
                field("Notification - API Routing"; "Notification - API Routing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification - API Routing field';
                }
                field("Notification - Conn. String"; "Notification - Conn. String")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification - Conn. String field';
                }
                field("Notification - Hub Path"; "Notification - Hub Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification - Hub Path field';
                }
            }
            group("Msg Service")
            {
                Caption = 'Msg Service';
                field("Msg Service - Site Created"; "Msg Service - Site Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - Site Created field';
                }
                field("Msg Service - API Key"; "Msg Service - API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - API Key field';
                }
                field("Msg Service - Base Url"; "Msg Service - Base Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - Base Url field';
                }
                field("Msg Service - Base Web Url"; "Msg Service - Base Web Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - Base Web Url field';
                }
                field("Msg Service - API Routing"; "Msg Service - API Routing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - API Routing field';
                }
                field("Msg Service - Name"; "Msg Service - Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - Name field';
                }
                field("Msg Service - Title"; "Msg Service - Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - Title field';
                }
                field("Msg Service - Description"; "Msg Service - Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - Description field';
                }
                field(WebsiteUrl; WebsiteUrl)
                {
                    ApplicationArea = All;
                    Caption = 'Msg Service - Website Url';
                    Editable = false;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the value of the Msg Service - Website Url field';
                }
                field("Msg Service - Report ID"; "Msg Service - Report ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - Report ID field';
                }
                field("Msg Service - Report Caption"; "Msg Service - Report Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - Report Caption field';
                }
                field("Msg Service - Source Type"; "Msg Service - Source Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - Source Type field';
                }
                field("Msg Service - Encryption Key"; "Msg Service - Encryption Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - Encryption Key field';
                }
                field("Msg Service - NAV WS User"; "Msg Service - NAV WS User")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - NAV WS User field';
                }
                field("Msg Service - NAV WS Password"; "Msg Service - NAV WS Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - NAV WS Password field';
                }
                field("Msg Service - Image"; "Msg Service - Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - Image field';
                }
                field("Msg Service - Icon"; "Msg Service - Icon")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Msg Service - Icon field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Test)
            {
                Caption = 'Test';
                Image = Task;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR AF Test Services";
                ApplicationArea = All;
                ToolTip = 'Executes the Test action';
            }
            action("Enable Webservice")
            {
                Caption = 'Enable Webservice';
                Image = "Action";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Codeunit "NPR AF API WebService";
                ApplicationArea = All;
                ToolTip = 'Executes the Enable Webservice action';

                trigger OnAction()
                var
                    AFHelperFunctions: Codeunit "NPR AF Helper Functions";
                begin
                    AFHelperFunctions.GetWebServiceUrl(Rec);
                end;
            }
            group("Notification Hub")
            {
                Caption = 'Notification Hub';
                action("Clear Customer Tag")
                {
                    Caption = 'Clear Customer Tag';
                    Image = Delete;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Clear Customer Tag action';

                    trigger OnAction()
                    var
                        AFHelperFunctions: Codeunit "NPR AF Helper Functions";
                    begin
                        AFHelperFunctions.ClearCustomerTag(Rec);
                    end;
                }
            }
            group(MSGService)
            {
                Caption = 'MSG Service';
                action("Create Site")
                {
                    Caption = 'Create Site';
                    Image = "Action";
                    RunObject = Codeunit "NPR AF API WebService";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Site action';

                    trigger OnAction()
                    var
                        AFAPIMsgService: Codeunit "NPR AF API - Msg Service";
                    begin
                        AFAPIMsgService.PostSiteInfo(Rec, 0);
                    end;
                }
                action("Update Site")
                {
                    Caption = 'Update Site';
                    Image = UpdateXML;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Update Site action';

                    trigger OnAction()
                    var
                        AFAPIMsgService: Codeunit "NPR AF API - Msg Service";
                    begin
                        AFAPIMsgService.PostSiteInfo(Rec, 1);
                    end;
                }
                action("Delete Site")
                {
                    Caption = 'Delete Site';
                    Image = Delete;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Delete Site action';

                    trigger OnAction()
                    var
                        AFAPIMsgService: Codeunit "NPR AF API - Msg Service";
                    begin
                        AFAPIMsgService.PostSiteInfo(Rec, 2);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        WebsiteUrl := "Msg Service - Base Web Url" + "Msg Service - Name";
    end;

    trigger OnModifyRecord(): Boolean
    begin
        WebsiteUrl := "Msg Service - Base Web Url" + "Msg Service - Name";
    end;

    var
        WebsiteUrl: Text;
}

