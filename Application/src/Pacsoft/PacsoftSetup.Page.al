page 6014574 "NPR Pacsoft Setup"
{
    // PS1.00/LS/20140509  CASE 190533 Pacsoft module Creation of Page
    // PS1.01/LS/20141216  CASE 200974 Added fields "Create Pacsoft Document" & Create Shipping Services Line
    // NPR5.00/RA/20160426  CASE 237639 Added field "Use Consignor"
    // NPR5.26/BHR/20160921 CASE 248912 Fields for pakkelabels
    // NPR5.29/BHR/20160921 CASE 248684 Field 'default weight' for pakkelabels
    // NPR5.36/BHR/20170711 CASE 283061 Add field "Use Pakkelable Printer API"
    // NPR5.36/BHR/20170920 CASE 290780 Field 'Send Delivery Instructions',  test connection to pakkelabels., check available balance
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer
    // NPR5.43/BHR/20180517 CASE 314692 Add field "Skip Pakkelabel Agreement"
    // NPR5.43/NPKNAV/20180629  CASE 304453 Transport NPR5.43 - 29 June 2018
    // NPR5.45/BHR /20180831 CASE 326205 Add field "Order No. to Ref." to Pakkelabel Tab

    Caption = 'Pacsoft Setup';
    PageType = Card;
    SourceTable = "NPR Pacsoft Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Use Pacsoft integration"; "Use Pacsoft integration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Pacsoft integration field';
                }
                field("Use Consignor"; "Use Consignor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Consignor field';
                }
                field("Package Service Codeunit ID"; "Package Service Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Package Service Codeunit ID field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempAllObjWithCaption: Record AllObjWithCaption temporary;
                    begin
                        //-NPR5.29 [248912]
                        GetPackageProvider(TempAllObjWithCaption);
                        if PAGE.RunModal(PAGE::"All Objects with Caption", TempAllObjWithCaption) = ACTION::LookupOK then begin
                            "Package Service Codeunit ID" := TempAllObjWithCaption."Object ID";
                            "Package ServiceCodeunit Name" := TempAllObjWithCaption."Object Name";
                        end;
                        //-NPR5.29 [248912]
                    end;
                }
                field("Package ServiceCodeunit Name"; "Package ServiceCodeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Package ServiceCodeunit Name field';
                }
            }
            group(Pacsoft)
            {
                field("Send Doc. Immediately(Pacsoft)"; "Send Doc. Immediately(Pacsoft)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Document Immediately field';
                }
                field("Sender QuickID"; "Sender QuickID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sender QuickID field';
                }
                field("Send Order URI"; "Send Order URI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Order URI field';
                }
                field(Session; Session)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Session field';
                }
                field(User; User)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User field';
                }
                field(Pin; Pin)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Password field';
                }
                field("Link to Print Message"; "Link to Print Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Link to Print Message field';
                }
                field("Order No. to Reference"; "Order No. to Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order No. to Reference field';
                }
                field("ENOT Message"; "ENOT Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ENOT Message field';
                }
                field("Return Label Both"; "Return Label Both")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Label Both field';
                }
                field("Shipping Agent Services Code"; "Shipping Agent Services Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Services Code field';
                }
                field("Create Pacsoft Document"; "Create Pacsoft Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Pacsoft Document field';
                }
                field("Create Shipping Services Line"; "Create Shipping Services Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Shipping Services Line field';
                }
            }
            group(Pakkelabels)
            {
                field("Api User"; "Api User")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api User field';
                }
                field("Api Key"; "Api Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Key field';
                }
                field("Send Package Doc. Immediately"; "Send Package Doc. Immediately")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Package Doc. Immediately field';
                }
                field("Default Weight"; "Default Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Weight field';
                }
                field("Use Pakkelable Printer API"; "Use Pakkelable Printer API")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Pakkelable Printer API field';
                }
                field("Pakkelable Test Mode"; "Pakkelable Test Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pakkelable Test Mode field';
                }
                group("Choose either ""Order No. to Reference"" or ""Order No. or Ext Doc No to ref""")
                {
                    Caption = 'Choose either "Order No. to Reference" or "Order No. or Ext Doc No to ref"';
                    field("Order No. to Ref"; "Order No. to Reference")
                    {
                        ApplicationArea = All;
                        Caption = 'Order No. to Reference';
                        ToolTip = 'Specifies the value of the Order No. to Reference field';
                    }
                    field("Order No. or Ext Doc No to ref"; "Order No. or Ext Doc No to ref")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Order No. or Ext Doc No to ref field';
                    }
                }
                field("Send Delivery Instructions"; "Send Delivery Instructions")
                {
                    ApplicationArea = All;
                    Caption = 'Send Delivery Instructions';
                    ToolTip = 'Specifies the value of the Send Delivery Instructions field';
                }
                field("Print Return Label"; "Print Return Label")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Return Label field';
                }
                field("Skip Own Agreement"; "Skip Own Agreement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Skip Own Agreement field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Test Connection")
            {
                Caption = 'Test Connection';
                Image = Server;
                ApplicationArea = All;
                ToolTip = 'Executes the Test Connection action';

                trigger OnAction()
                begin
                    //-290780 [290780]
                end;
            }
            action("Check Balance")
            {
                Caption = 'Check Balance';
                Image = Balance;
                ApplicationArea = All;
                ToolTip = 'Executes the Check Balance action';

                trigger OnAction()
                begin
                    //-290780 [290780]
                end;
            }
        }
    }

    [IntegrationEvent(TRUE, FALSE)]
    procedure GetPackageProvider(var tmpAllObjWithCaption: Record AllObjWithCaption temporary)
    begin
        //-NPR5.29 [248912]
    end;
}

