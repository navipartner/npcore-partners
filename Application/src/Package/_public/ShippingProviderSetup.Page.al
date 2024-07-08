page 6014574 "NPR Shipping Provider Setup"
{
    Extensible = true;
    Caption = 'Shipping Provider Setup';
    PageType = Card;
    SourceTable = "NPR Shipping Provider Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field("Enable Shipping"; Rec."Enable Shipping")
                {
                    ToolTip = 'Enables Shipping Service';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Provider"; rec."Shipping Provider")
                {
                    ToolTip = 'Specifies the Shipping Provider To Use';
                    ApplicationArea = NPRRetail;
                }
                field("Api User"; Rec."Api User")
                {
                    ToolTip = 'Specifies the value of the Api User field.';
                    ApplicationArea = NPRRetail;
                }
                field("Api Key"; Rec."Api Key")
                {
                    ToolTip = 'Specifies the value of the Api Key field.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Pacsoft)
            {
                field("Send Doc. Immediately(Pacsoft)"; Rec."Send Doc. Immediately(Pacsoft)")
                {

                    ToolTip = 'Specifies the value of the Send Document Immediately field';
                    ApplicationArea = NPRRetail;
                }
                field("Sender QuickID"; Rec."Sender QuickID")
                {

                    ToolTip = 'Specifies the value of the Sender QuickID field';
                    ApplicationArea = NPRRetail;
                }
                field("Send Order URI"; Rec."Send Order URI")
                {

                    ToolTip = 'Specifies the value of the Send Order URI field';
                    ApplicationArea = NPRRetail;
                }
                field(Session; Rec.Session)
                {

                    ToolTip = 'Specifies the value of the Session field';
                    ApplicationArea = NPRRetail;
                }
                field(User; Rec.User)
                {

                    ToolTip = 'Specifies the value of the User field';
                    ApplicationArea = NPRRetail;
                }
                field(Pin; Rec.Pin)
                {

                    ToolTip = 'Specifies the value of the Password field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Online Connect"; Rec."Use Online Connect")
                {
                    ToolTip = 'Specifies the value of the Use Online Connect field.';
                    ApplicationArea = NPRRetail;
                }
                field("Online Connect file Path"; Rec."Online Connect file Path")
                {
                    ToolTip = 'Specifies the value of the Online Connect file Path field.';
                    ApplicationArea = NPRRetail;
                }
                field("Link to Print Message"; Rec."Link to Print Message")
                {

                    ToolTip = 'Specifies the value of the Link to Print Message field';
                    ApplicationArea = NPRRetail;
                }
                field("Order No. to Reference"; Rec."Order No. to Reference")
                {

                    ToolTip = 'Specifies the value of the Order No. to Reference field';
                    ApplicationArea = NPRRetail;
                }
                field("ENOT Message"; Rec."ENOT Message")
                {

                    ToolTip = 'Specifies the value of the ENOT Message field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Label Both"; Rec."Return Label Both")
                {

                    ToolTip = 'Specifies the value of the Return Label Both field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Agent Services Code"; Rec."Shipping Agent Services Code")
                {

                    ToolTip = 'Specifies the value of the Shipping Agent Services Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Pacsoft Document"; Rec."Create Pacsoft Document")
                {

                    ToolTip = 'Specifies the value of the Create Pacsoft Document field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Shipping Services Line"; Rec."Create Shipping Services Line")
                {

                    ToolTip = 'Specifies the value of the Create Shipping Services Line field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Pakkelabels)
            {
                field("Send Package Doc. Immediately"; Rec."Send Package Doc. Immediately")
                {

                    ToolTip = 'Specifies the value of the Send Package Doc. Immediately field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Weight"; Rec."Default Weight")
                {

                    ToolTip = 'Specifies the value of the Default Weight field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Height"; Rec."Default Height")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Default Height field.';
                }

                field("Default Length"; Rec."Default Length")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Default Length field.';
                }

                field("Default Width"; Rec."Default Width")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Default Width field.';
                }
                field("Use Pakkelable Printer API"; Rec."Use Pakkelable Printer API")
                {

                    ToolTip = 'Specifies the value of the Use Pakkelable Printer API field';
                    ApplicationArea = NPRRetail;
                }
                field("Pakkelable Test Mode"; Rec."Pakkelable Test Mode")
                {

                    ToolTip = 'Specifies the value of the Pakkelable Test Mode field';
                    ApplicationArea = NPRRetail;
                }
                group("Choose either Order No. to Reference or Order No. or Ext Doc No to ref")
                {
                    Caption = 'Choose either "Order No. to Reference" or "Order No. or Ext Doc No to ref"';
                    field("Order No. to Ref"; Rec."Order No. to Reference")
                    {

                        Caption = 'Order No. to Reference';
                        ToolTip = 'Specifies the value of the Order No. to Reference field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Order No. or Ext Doc No to ref"; Rec."Order No. or Ext Doc No to ref")
                    {

                        ToolTip = 'Specifies the value of the Order No. or Ext Doc No to ref field';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Send Delivery Instructions"; Rec."Send Delivery Instructions")
                {

                    Caption = 'Send Delivery Instructions';
                    ToolTip = 'Specifies the value of the Send Delivery Instructions field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Return Label"; Rec."Print Return Label")
                {

                    ToolTip = 'Specifies the value of the Print Return Label field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Test Connection action';
                ApplicationArea = NPRRetail;

            }
            action("Check Balance")
            {
                Caption = 'Check Balance';
                Image = Balance;

                ToolTip = 'Executes the Check Balance action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ShippingProviderSetup: record "NPR Shipping Provider Setup";

                begin
                    if ShippingProviderSetup.get() then
                        GetBalance(ShippingProviderSetup."Shipping Provider");
                end;
            }
            action("Shipment Mapping(Foreign Countries)")
            {
                Image = FiledOverview;
                Caption = 'Mapping(Foreign Countries)';
                RunObject = Page "NPR Pakke Foreign Shipm. Map.";

                ToolTip = 'Executes the Mapping(Foreign Countries) action';
                ApplicationArea = NPRRetail;
            }
            action("Pakkelabels Printers")
            {
                Image = PrintInstallment;
                Caption = 'Printer';
                RunObject = Page "NPR Package Printers";

                ToolTip = 'Executes the Printer action';
                ApplicationArea = NPRRetail;
            }
            action("Pakkelabels Shipping Agent")
            {
                Image = ServiceCode;
                Caption = 'Shipping Agents';
                RunObject = Page "NPR Package Shipping agents";

                ToolTip = 'Executes the Shipping Agents action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not rec.Get() then begin
            rec.Init();
            rec.Insert();
        end;
    end;

    local procedure GetBalance(IShippingProvider: Interface "NPR IShipping Provider Interface")
    begin
        IShippingProvider.CheckBalance();
    end;
}

