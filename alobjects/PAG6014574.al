page 6014574 "Pacsoft Setup"
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
    SourceTable = "Pacsoft Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Use Pacsoft integration";"Use Pacsoft integration")
                {
                }
                field("Use Consignor";"Use Consignor")
                {
                }
                field("Package Service Codeunit ID";"Package Service Codeunit ID")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempAllObjWithCaption: Record AllObjWithCaption temporary;
                    begin
                        //-NPR5.29 [248912]
                        GetPackageProvider(TempAllObjWithCaption);
                        if PAGE.RunModal(PAGE::"All Objects with Caption",TempAllObjWithCaption) = ACTION::LookupOK then begin
                          "Package Service Codeunit ID" := TempAllObjWithCaption."Object ID";
                          "Package ServiceCodeunit Name" := TempAllObjWithCaption."Object Name";
                        end;
                        //-NPR5.29 [248912]
                    end;
                }
                field("Package ServiceCodeunit Name";"Package ServiceCodeunit Name")
                {
                }
            }
            group(Pacsoft)
            {
                field("Send Doc. Immediately(Pacsoft)";"Send Doc. Immediately(Pacsoft)")
                {
                }
                field("Sender QuickID";"Sender QuickID")
                {
                }
                field("Send Order URI";"Send Order URI")
                {
                }
                field(Session;Session)
                {
                }
                field(User;User)
                {
                }
                field(Pin;Pin)
                {
                }
                field("Link to Print Message";"Link to Print Message")
                {
                }
                field("Order No. to Reference";"Order No. to Reference")
                {
                }
                field("ENOT Message";"ENOT Message")
                {
                }
                field("Return Label Both";"Return Label Both")
                {
                }
                field("Shipping Agent Services Code";"Shipping Agent Services Code")
                {
                }
                field("Create Pacsoft Document";"Create Pacsoft Document")
                {
                }
                field("Create Shipping Services Line";"Create Shipping Services Line")
                {
                }
            }
            group(Pakkelabels)
            {
                field("Api User";"Api User")
                {
                }
                field("Api Key";"Api Key")
                {
                }
                field("Send Package Doc. Immediately";"Send Package Doc. Immediately")
                {
                }
                field("Default Weight";"Default Weight")
                {
                }
                field("Use Pakkelable Printer API";"Use Pakkelable Printer API")
                {
                }
                field("Pakkelable Test Mode";"Pakkelable Test Mode")
                {
                }
                group("Choose either ""Order No. to Reference"" or ""Order No. or Ext Doc No to ref""")
                {
                    Caption = 'Choose either "Order No. to Reference" or "Order No. or Ext Doc No to ref"';
                    field("Order No. to Ref";"Order No. to Reference")
                    {
                        Caption = 'Order No. to Reference';
                    }
                    field("Order No. or Ext Doc No to ref";"Order No. or Ext Doc No to ref")
                    {
                    }
                }
                field("Send Delivery Instructions";"Send Delivery Instructions")
                {
                    Caption = 'Send Delivery Instructions';
                }
                field("Print Return Label";"Print Return Label")
                {
                }
                field("Skip Own Agreement";"Skip Own Agreement")
                {
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

                trigger OnAction()
                begin
                    //-290780 [290780]
                end;
            }
            action("Check Balance")
            {
                Caption = 'Check Balance';
                Image = Balance;

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

