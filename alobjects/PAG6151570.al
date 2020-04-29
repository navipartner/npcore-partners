page 6151570 "AF Setup"
{
    // NPR5.36/NPKNAV/20171003  CASE 269792 Transport NPR5.36 - 3 October 2017
    // NPR5.38/CLVA/20171024 CASE 289636 Added Messages Service fields
    // NPR5.38/CLVA/20180123 CASE 279861 Added OIO Validation fields
    // NPR5.43/CLVA/20180529 CASE 279861 Added field "OIO Validation - Enable"

    Caption = 'AF Setup';
    PageType = Card;
    SourceTable = "AF Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Enable Azure Functions";"Enable Azure Functions")
                {
                }
                field("Customer Tag";"Customer Tag")
                {
                }
                field("Web Service Is Published";"Web Service Is Published")
                {
                }
                field("Web Service Url";"Web Service Url")
                {
                }
            }
            group("Spire Barcode")
            {
                Caption = 'Spire Barcode';
                field("Spire Barcode - API Key";"Spire Barcode - API Key")
                {
                }
                field("Spire Barcode - Base Url";"Spire Barcode - Base Url")
                {
                }
                field("Spire Barcode - API Routing";"Spire Barcode - API Routing")
                {
                }
            }
            group(Control6014405)
            {
                Caption = 'Notification Hub';
                field("Notification - API Key";"Notification - API Key")
                {
                }
                field("Notification - Base Url";"Notification - Base Url")
                {
                }
                field("Notification - API Routing";"Notification - API Routing")
                {
                }
                field("Notification - Conn. String";"Notification - Conn. String")
                {
                }
                field("Notification - Hub Path";"Notification - Hub Path")
                {
                }
            }
            group("Msg Service")
            {
                Caption = 'Msg Service';
                field("Msg Service - Site Created";"Msg Service - Site Created")
                {
                }
                field("Msg Service - API Key";"Msg Service - API Key")
                {
                }
                field("Msg Service - Base Url";"Msg Service - Base Url")
                {
                }
                field("Msg Service - Base Web Url";"Msg Service - Base Web Url")
                {
                }
                field("Msg Service - API Routing";"Msg Service - API Routing")
                {
                }
                field("Msg Service - Name";"Msg Service - Name")
                {
                }
                field("Msg Service - Title";"Msg Service - Title")
                {
                }
                field("Msg Service - Description";"Msg Service - Description")
                {
                }
                field(WebsiteUrl;WebsiteUrl)
                {
                    Caption = 'Msg Service - Website Url';
                    Editable = false;
                    ExtendedDatatype = URL;
                }
                field("Msg Service - Report ID";"Msg Service - Report ID")
                {
                }
                field("Msg Service - Report Caption";"Msg Service - Report Caption")
                {
                }
                field("Msg Service - Source Type";"Msg Service - Source Type")
                {
                }
                field("Msg Service - Encryption Key";"Msg Service - Encryption Key")
                {
                }
                field("Msg Service - NAV WS User";"Msg Service - NAV WS User")
                {
                }
                field("Msg Service - NAV WS Password";"Msg Service - NAV WS Password")
                {
                }
                field("Msg Service - Image";"Msg Service - Image")
                {
                }
                field("Msg Service - Icon";"Msg Service - Icon")
                {
                }
            }
            group("OIO Validation")
            {
                Caption = 'OIO Validation';
                field("OIO Validation - Enable";"OIO Validation - Enable")
                {
                }
                field("OIO Validation - API Key";"OIO Validation - API Key")
                {
                }
                field("OIO Validation - Base Url";"OIO Validation - Base Url")
                {
                }
                field("OIO Validation - API Routing";"OIO Validation - API Routing")
                {
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "AF Test Services";
            }
            action("Enable Webservice")
            {
                Caption = 'Enable Webservice';
                Image = "Action";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Codeunit "AF API WebService";

                trigger OnAction()
                var
                    AFHelperFunctions: Codeunit "AF Helper Functions";
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

                    trigger OnAction()
                    var
                        AFHelperFunctions: Codeunit "AF Helper Functions";
                    begin
                        AFHelperFunctions.ClearCustomerTag(Rec);
                    end;
                }
            }
            group("MSG Service")
            {
                Caption = 'MSG Service';
                action("Create Site")
                {
                    Caption = 'Create Site';
                    Image = "Action";
                    RunObject = Codeunit "AF API WebService";

                    trigger OnAction()
                    var
                        AFAPIMsgService: Codeunit "AF API - Msg Service";
                    begin
                        AFAPIMsgService.PostSiteInfo(Rec,0);
                    end;
                }
                action("Update Site")
                {
                    Caption = 'Update Site';
                    Image = UpdateXML;

                    trigger OnAction()
                    var
                        AFAPIMsgService: Codeunit "AF API - Msg Service";
                    begin
                        AFAPIMsgService.PostSiteInfo(Rec,1);
                    end;
                }
                action("Delete Site")
                {
                    Caption = 'Delete Site';
                    Image = Delete;

                    trigger OnAction()
                    var
                        AFAPIMsgService: Codeunit "AF API - Msg Service";
                    begin
                        AFAPIMsgService.PostSiteInfo(Rec,2);
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

